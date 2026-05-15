import Foundation
import SwiftUI
import Combine
import Supabase
import Realtime
import AgoraRtcKit

@MainActor class ActiveSessionViewModel: ObservableObject {
    let roundtable: Roundtable
    
    @Published var participants: [RoundtableParticipant] = []
    @Published var messages: [RoundtableMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserId: UUID?
    
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
        // Forward AgoraManager updates to our view
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
            
            // Setup Agora
            setupAgora()
            
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func setupAgora() {
        guard let userId = currentUserId else { return }
        
        // Convert UUID to a numeric UID for Agora
        let numericUid = UInt(abs(userId.uuidString.hashValue))
        
        // Check if user is a speaker or moderator based on roundtable logic
        // For now, let's assume everyone can speak if they are in the 'broadcaster' list
        // or if they are the moderator.
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
    
    func toggleMute() {
        agoraManager.toggleMute()
    }
    
    func toggleCamera() {
        agoraManager.toggleCamera()
    }
    
    func requestFloor() {
        // Here we would update the roundtable_participants table status to 'requesting_floor'
        // And notify others via Realtime.
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
