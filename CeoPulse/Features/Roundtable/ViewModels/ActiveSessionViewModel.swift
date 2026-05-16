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
                try await service.joinRoundtable(roundtableId: roundtable.id, role: .listener)
                fetchedParticipants = try await service.fetchParticipants(roundtableId: roundtable.id)
            }
            
            self.participants = fetchedParticipants
            self.messages = try await service.fetchMessages(roundtableId: roundtable.id)
            self.transcripts = try await service.fetchTranscripts(roundtableId: roundtable.id)
            
            await setupRealtime()
            setupAgora()
            updateAgoraState()
            
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func setupAgora() {
        guard let userId = currentUserId else { return }
        let numericUid = UInt(abs(userId.uuidString.hashValue))
        let role: AgoraClientRole = (roundtable.moderatorId == userId) ? .broadcaster : .audience
        
        agoraManager.joinChannel(
            channelName: roundtable.id.uuidString,
            userId: numericUid,
            role: role
        )
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
