import Foundation
import SwiftUI
import Combine
import Supabase
import Realtime
import AgoraRtcKit

@MainActor class ActiveSessionViewModel: ObservableObject {
    @Published var roundtable: Roundtable
    
    @Published var participants: [RoundtableParticipant] = []
    @Published var messages: [RoundtableMessage] = []
    @Published var transcripts: [RoundtableTranscript] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserId: UUID?
    
    var isRequestingFloor: Bool {
        participants.first(where: { $0.userId == currentUserId })?.isRequestingFloor ?? false
    }
    
    var currentSpeakerName: String? {
        if let speakerId = roundtable.currentSpeakerId {
            if speakerId == currentUserId { return "Sen" }
            return participants.first(where: { $0.userId == speakerId })?.userName ?? "Biri"
        }
        return nil
    }
    
    // RTC States observed from AgoraManager
    @ObservedObject var agoraManager = AgoraManager.shared
    
    private let service = RoundtableService.shared
    private let client = SupabaseManager.shared.client
    private var channel: RealtimeChannelV2?
    private var cancellables = Set<AnyCancellable>()
    
    init(roundtable: Roundtable) {
        self.roundtable = roundtable
        self.currentUserId = client.auth.currentSession?.user.id
        
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        agoraManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func setupSession() async {
        isLoading = true
        errorMessage = nil
        
        if currentUserId == nil {
            currentUserId = try? await client.auth.session.user.id
        }
        
        do {
            var fetchedParticipants = try await service.fetchParticipants(roundtableId: roundtable.id)
            
            // Auto-join if not already a participant
            if let userId = currentUserId, !fetchedParticipants.contains(where: { $0.userId == userId }) {
                let numericUid = deterministicHash(userId)
                try await service.joinRoundtable(roundtableId: roundtable.id, role: .listener, agoraUid: numericUid)
                fetchedParticipants = try await service.fetchParticipants(roundtableId: roundtable.id)
            }
            
            self.participants = fetchedParticipants
            self.messages = try await service.fetchMessages(roundtableId: roundtable.id)
            self.transcripts = try await service.fetchTranscripts(roundtableId: roundtable.id)
            
            await setupRealtime()
            
            // Start AI transcription FIRST to get a valid RTC token for this user.
            // The token is required because App Certificate is active on this Agora project.
            // We join the Agora channel only AFTER we have the token.
            let agoraToken = await startTranscription()
            setupAgora(token: agoraToken)
            updateAgoraState()
            
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func setupAgora(token: String? = nil) {
        guard let userId = currentUserId else { return }
        let numericUid = deterministicHash(userId)
        let role: AgoraClientRole = (roundtable.moderatorId == userId) ? .broadcaster : .audience
        
        // Update agora_uid in database just in case
        Task {
            try? await service.updateAgoraUid(roundtableId: roundtable.id, agoraUid: numericUid)
        }
        
        agoraManager.joinChannel(
            channelName: roundtable.id.uuidString.lowercased(),  // MUST match STT bot's channelName
            userId: numericUid,
            role: role,
            token: token
        )
        
        // Wire up STT transcript callback from pubBot stream messages
        let roundtableId = roundtable.id
        agoraManager.onTranscriptReceived = { [weak self] text in
            guard let self = self else { return }
            
            // Deduplication: Only the moderator (or the active speaker if moderator is absent) saves to the DB.
            let isModerator = self.roundtable.moderatorId == self.currentUserId
            let activeSpeakerId = self.roundtable.currentSpeakerId
            let isCurrentSpeaker = activeSpeakerId == self.currentUserId
            
            // Check if moderator is currently in the active participants list
            let isModeratorPresent = self.participants.contains { $0.userId == self.roundtable.moderatorId }
            
            let shouldSave = isModerator || (!isModeratorPresent && isCurrentSpeaker)
            
            if shouldSave {
                print("[STT] This device is saving transcript: \"\(text)\" (Moderator: \(isModerator), Speaker: \(isCurrentSpeaker))")
                Task {
                    do {
                        try await self.service.saveTranscript(
                            roundtableId: roundtableId,
                            content: text,
                            userId: activeSpeakerId
                        )
                        print("[STT] Transcript saved successfully to Supabase")
                    } catch {
                        print("[STT] Error saving transcript to Supabase: \(error.localizedDescription)")
                    }
                }
            } else {
                print("[STT] Transcript received but skipping write (another peer is responsible): \"\(text)\"")
            }
        }
    }
    
    private func setupRealtime() async {
        let channelId = "roundtable:\(roundtable.id.uuidString)"
        channel = client.realtimeV2.channel(channelId)
        
        // Listen for current speaker changes
        _ = channel?.onPostgresChange(
            UpdateAction.self,
            schema: "public",
            table: "roundtables"
        ) { [weak self] action in
            print("DEBUG: Realtime Update received for table roundtables")
            guard let self = self else { return }
            // Get current_speaker_id from the record
            if let speakerIdString = action.record["current_speaker_id"]?.value as? String,
               let speakerId = UUID(uuidString: speakerIdString) {
                Task { @MainActor in
                    self.roundtable.currentSpeakerId = speakerId
                }
            } else {
                Task { @MainActor in
                    self.roundtable.currentSpeakerId = nil
                }
            }
        }
        
        _ = channel?.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "roundtable_messages"
        ) { [weak self] _ in
            print("DEBUG: Realtime Insert received for table roundtable_messages")
            guard let self = self else { return }
            Task { @MainActor in self.refreshMessages() }
        }
        
        _ = channel?.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "roundtable_participants"
        ) { [weak self] _ in
            print("DEBUG: Realtime Insert received for table roundtable_participants")
            guard let self = self else { return }
            Task { @MainActor in self.refreshParticipants() }
        }
        
        _ = channel?.onPostgresChange(
            UpdateAction.self,
            schema: "public",
            table: "roundtable_participants"
        ) { [weak self] _ in
            print("DEBUG: Realtime Update received for table roundtable_participants")
            guard let self = self else { return }
            Task { @MainActor in self.refreshParticipants() }
        }
        
        _ = channel?.onPostgresChange(
            DeleteAction.self,
            schema: "public",
            table: "roundtable_participants"
        ) { [weak self] _ in
            print("DEBUG: Realtime Delete received for table roundtable_participants")
            guard let self = self else { return }
            Task { @MainActor in self.refreshParticipants() }
        }
        
        _ = channel?.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "roundtable_transcripts"
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.refreshTranscripts() }
        }
        
        do {
            try await channel?.subscribeWithError()
        } catch {
            print("Realtime subscription error: \(error)")
        }
    }
    
    private func updateAgoraState() {
        guard let userId = currentUserId else { return }
        
        let stageParticipants = participants.filter { $0.role == .moderator || $0.role == .speaker }
        let isOnStage = stageParticipants.contains { $0.userId == userId }
        
        let shouldBeBroadcaster = isOnStage
        let currentRole: AgoraClientRole = shouldBeBroadcaster ? .broadcaster : .audience
        
        agoraManager.setRole(currentRole)
        agoraManager.setMute(!shouldBeBroadcaster)
    }

    private func refreshParticipants() {
        Task {
            do {
                let refreshedParticipants = try await self.service.fetchParticipants(roundtableId: self.roundtable.id)
                await MainActor.run {
                    self.participants = refreshedParticipants
                    self.updateAgoraState()
                }
            } catch {
                print("Error refreshing participants: \(error)")
            }
        }
    }
    
    private func refreshMessages() {
        Task {
            do {
                let refreshedMessages = try await self.service.fetchMessages(roundtableId: self.roundtable.id)
                await MainActor.run {
                    self.messages = refreshedMessages
                }
            } catch {
                print("Error refreshing messages: \(error)")
            }
        }
    }
    
    private func refreshTranscripts() {
        Task {
            do {
                let refreshedTranscripts = try await self.service.fetchTranscripts(roundtableId: self.roundtable.id)
                
                // Map user data from participants
                let enrichedTranscripts = refreshedTranscripts.map { transcript -> RoundtableTranscript in
                    var t = transcript
                    if let participant = self.participants.first(where: { $0.userId == transcript.userId }) {
                        t.userName = participant.userName
                        t.userAvatar = participant.userAvatar
                        t.userTitle = participant.userTitle
                    }
                    return t
                }
                
                await MainActor.run {
                    self.transcripts = enrichedTranscripts
                }
            } catch {
                print("Error refreshing transcripts: \(error)")
            }
        }
    }
    
    func sendMessage(_ content: String) async {
        guard !content.isEmpty else { return }
        do {
            try await service.sendMessage(roundtableId: roundtable.id, content: content)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    // Returns the RTC token for the calling user, or nil if unavailable.
    @discardableResult
    private func startTranscription() async -> String? {
        guard let userId = currentUserId else { return nil }
        let numericUid = deterministicHash(userId)
        
        do {
            struct TranscriptionParams: Encodable {
                let roundtableId: String
                let channelName: String
                let userUid: UInt  // so Edge Function can generate a token for this user
            }
            
            let params = TranscriptionParams(
                roundtableId: roundtable.id.uuidString.lowercased(),
                channelName: roundtable.id.uuidString.lowercased(),
                userUid: numericUid
            )
            
            struct TranscriptionResponse: Decodable {
                let agent_id: String?
                let userToken: String?
            }
            
            let data = try await SupabaseManager.shared.client.functions
                .invoke("start-transcription", options: .init(body: params))
            
            let response = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
            print("AI Transcription service started successfully")
            
            if let token = response.userToken {
                print("[AGORA-TOKEN] Received RTC token from Edge Function ✓")
            } else {
                print("[AGORA-TOKEN] No userToken in response — will join without token (may fail)")
            }
            
            return response.userToken
        } catch {
            print("Note: AI Transcription start failed or already running: \(error)")
            return nil
        }
    }
    
    // MARK: - RTC Controls
    
    func handlePTT(isPressing: Bool) {
        Task {
            do {
                if isPressing {
                    // Grab mic in DB
                    try await service.updateCurrentSpeaker(roundtableId: roundtable.id, userId: currentUserId)
                    // Unmute in Agora
                    agoraManager.toggleMute() // This will unmute if it was muted
                } else {
                    // Release mic in DB
                    try await service.updateCurrentSpeaker(roundtableId: roundtable.id, userId: nil)
                    // Mute in Agora
                    agoraManager.toggleMute() // This will mute back
                }
            } catch {
                print("Error handling PTT: \(error)")
            }
        }
    }
    
    func toggleMute() {
        agoraManager.toggleMute()
    }
    
    func toggleCamera() {
        agoraManager.toggleCamera()
    }
    
    func requestFloor() {
        guard let userId = currentUserId else { 
            print("DEBUG: requestFloor failed - currentUserId is nil")
            return 
        }
        
        print("DEBUG: requestFloor called for user: \(userId)")
        
        let stageCount = participants.filter { $0.role == .moderator || $0.role == .speaker }.count
        let isStageFull = stageCount >= 4
        
        if let participant = participants.first(where: { $0.userId == userId }) {
            print("DEBUG: Found participant row, current role: \(participant.role)")
            Task {
                do {
                    if isStageFull {
                        let newState = !participant.isRequestingFloor
                        print("DEBUG: Stage full, updating participant \(participant.id) isRequesting: \(newState)")
                        try await service.updateParticipant(id: participant.id, role: participant.role, isRequestingFloor: newState)
                    } else {
                        print("DEBUG: Stage not full, promoting participant \(participant.id) to speaker")
                        try await service.updateParticipant(id: participant.id, role: .speaker, isRequestingFloor: false)
                    }
                    // Fail-safe: Refresh manually after update
                    refreshParticipants()
                } catch {
                    print("DEBUG: Error in requestFloor task: \(error)")
                }
            }
        } else {
            print("DEBUG: Participant row NOT FOUND for user \(userId) in list of \(participants.count) people")
        }
    }
    
    
    private func deterministicHash(_ uuid: UUID) -> UInt {
        let s = uuid.uuidString.lowercased()
        var h: UInt = 5381
        for byte in s.utf8 {
            h = ((h << 5) &+ h) &+ UInt(byte)
        }
        return h & 0x7FFFFFFF  // mask to 31-bit: always fits in Int, always positive
    }
    
    func leaveSession() {
        agoraManager.leaveChannel()
        let taskChannel = channel
        Task {
            await taskChannel?.unsubscribe()
            try? await service.leaveRoundtable(roundtableId: roundtable.id)
        }
    }
    
    func leaveStage() {
        guard let userId = currentUserId else { return }
        Task {
            do {
                try await service.updateRole(roundtableId: roundtable.id, userId: userId, role: .listener)
                refreshParticipants()
            } catch {
                print("Error leaving stage: \(error)")
            }
        }
    }
}
