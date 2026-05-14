// UPDATED_BY_ANTIGRAVITY_v3
import Foundation
import SwiftUI
import Combine
import Supabase
import Realtime

// ViewModel to manage active roundtable sessions and real-time updates
@MainActor class ActiveSessionViewModel: ObservableObject {
    let roundtable: Roundtable
    
    @Published var participants: [RoundtableParticipant] = []
    @Published var messages: [RoundtableMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserId: UUID?
    
    private let service = RoundtableService.shared
    private let client = SupabaseManager.shared.client
    private var channel: RealtimeChannelV2?
    
    init(roundtable: Roundtable) {
        self.roundtable = roundtable
        self.currentUserId = client.auth.currentSession?.user.id
    }
    
    func setupSession() async {
        isLoading = true
        errorMessage = nil
        
        // Ensure current user is set
        if currentUserId == nil {
            currentUserId = try? await client.auth.session.user.id
        }
        
        do {
            // 1. Initial Load
            self.participants = try await service.fetchParticipants(roundtableId: roundtable.id)
            self.messages = try await service.fetchMessages(roundtableId: roundtable.id)
            
            // 2. Setup Realtime
            setupRealtime()
            
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func setupRealtime() {
        let channelId = "roundtable:\(roundtable.id.uuidString)"
        channel = client.realtimeV2.channel(channelId)
        
        // Listen for new messages
        _ = channel?.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "roundtable_messages",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)",
            callback: { [weak self] _ in
                self?.refreshMessages()
            }
        )
        
        // Listen for participant changes
        _ = channel?.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "roundtable_participants",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)",
            callback: { [weak self] _ in
                self?.refreshParticipants()
            }
        )
        
        _ = channel?.onPostgresChange(
            UpdateAction.self,
            schema: "public",
            table: "roundtable_participants",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)",
            callback: { [weak self] _ in
                self?.refreshParticipants()
            }
        )
        
        _ = channel?.onPostgresChange(
            DeleteAction.self,
            schema: "public",
            table: "roundtable_participants",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)",
            callback: { [weak self] _ in
                self?.refreshParticipants()
            }
        )
        
        channel?.subscribe { _ in }
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
    
    func leaveSession() {
        channel?.unsubscribe()
        Task {
            try? await service.leaveRoundtable(roundtableId: roundtable.id)
        }
    }
    
    deinit {
        channel?.unsubscribe()
    }
}
