// UPDATED_BY_ANTIGRAVITY_v2
import Foundation
import SwiftUI
import Combine
import Supabase
import Realtime

// ViewModel to manage active roundtable sessions and real-time updates
class ActiveSessionViewModel: ObservableObject {
    let roundtable: Roundtable
    
    @Published var participants: [RoundtableParticipant] = []
    @Published var messages: [RoundtableMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = RoundtableService.shared
    private let client = SupabaseManager.shared.client
    private var channel: RealtimeChannelV2?
    
    init(roundtable: Roundtable) {
        self.roundtable = roundtable
    }
    
    @MainActor
    func setupSession() async {
        isLoading = true
        errorMessage = nil
        
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
        channel = client.realtimeV2.channel(.init(name: channelId))
        
        // Listen for new messages
        channel?.onPostgresChange(
            .insert,
            schema: "public",
            table: "roundtable_messages",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)"
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if let refreshedMessages = try? await self.service.fetchMessages(roundtableId: self.roundtable.id) {
                    self.messages = refreshedMessages
                }
            }
        }
        
        // Listen for participant changes
        channel?.onPostgresChange(
            .all,
            schema: "public",
            table: "roundtable_participants",
            filter: "roundtable_id=eq.\(roundtable.id.uuidString)"
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if let refreshedParticipants = try? await self.service.fetchParticipants(roundtableId: self.roundtable.id) {
                    self.participants = refreshedParticipants
                }
            }
        }
        
        channel?.subscribe { _ in }
    }
    
    @MainActor
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
