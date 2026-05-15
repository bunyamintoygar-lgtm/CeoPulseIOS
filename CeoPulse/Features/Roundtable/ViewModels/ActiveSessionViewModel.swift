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
            self.participants = try await service.fetchParticipants(roundtableId: roundtable.id)
            self.messages = try await service.fetchMessages(roundtableId: roundtable.id)
            
            await setupRealtime()
            setupAgora()
            
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
            table: "roundtables",
            filter: "id=eq.\(roundtable.id.uuidString)"
        ) { [weak self] action in
            guard let self = self else { return }
            if let updatedRoundtable = try? action.decode(as: Roundtable.self) {
                Task { @MainActor in
                    self.roundtable.currentSpeakerId = updatedRoundtable.currentSpeakerId
                }
            }
        }
        
        _ = channel?.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "roundtable_messages",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)"
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.refreshMessages() }
        }
        
        _ = channel?.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "roundtable_participants",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)"
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.refreshParticipants() }
        }
        
        _ = channel?.onPostgresChange(
            UpdateAction.self,
            schema: "public",
            table: "roundtable_participants",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)"
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.refreshParticipants() }
        }
        
        _ = channel?.onPostgresChange(
            DeleteAction.self,
            schema: "public",
            table: "roundtable_participants",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)"
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.refreshParticipants() }
        }
        
        await channel?.subscribe()
    }
    
    private func refreshParticipants() {
        Task {
            if let refreshedParticipants = try? await self.service.fetchParticipants(roundtableId: self.roundtable.id) {
                self.participants = refreshedParticipants
            }
        }
    }
    
    private func refreshMessages() {
        Task {
            if let refreshedMessages = try? await self.service.fetchMessages(roundtableId: self.roundtable.id) {
                self.messages = refreshedMessages
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
        guard let userId = currentUserId else { return }
        if let participant = participants.first(where: { $0.userId == userId }) {
            let newState = !participant.isRequestingFloor
            Task {
                do {
                    try await service.requestFloor(roundtableId: roundtable.id, isRequesting: newState)
                } catch {
                    print("Error requesting floor: \(error)")
                }
            }
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
}
