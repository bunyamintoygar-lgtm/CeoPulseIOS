import Foundation
import Supabase
import PostgREST
import Realtime

class RoundtableService {
    static let shared = RoundtableService()
    private let client = SupabaseManager.shared.client
    
    private init() {}
    
    // MARK: - Fetching
    
    func fetchRoundtables(status: RoundtableStatus? = nil, category: String? = nil) async throws -> [Roundtable] {
        var query = client.from("roundtables").select()
        
        if let status = status {
            query = query.eq("status", value: status.rawValue)
        }
        
        if let category = category, category != "Tümü" {
            query = query.eq("category", value: category)
        }
        
        let roundtables: [Roundtable] = try await query.order("start_time", ascending: true).execute().value
        return roundtables
    }
    
    func fetchParticipants(roundtableId: UUID) async throws -> [RoundtableParticipant] {
        // In a real app, we would join with profiles table here
        let participants: [RoundtableParticipant] = try await client.from("roundtable_participants")
            .select()
            .eq("roundtable_id", value: roundtableId.uuidString)
            .execute()
            .value
        return participants
    }
    
    func fetchMessages(roundtableId: UUID) async throws -> [RoundtableMessage] {
        let messages: [RoundtableMessage] = try await client.from("roundtable_messages")
            .select()
            .eq("roundtable_id", value: roundtableId.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value
        return messages
    }
    
    // MARK: - Actions
    
    func joinRoundtable(roundtableId: UUID, role: RoundtableRole = .listener) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        let participant = [
            "roundtable_id": roundtableId.uuidString,
            "user_id": userId.uuidString,
            "role": role.rawValue
        ]
        
        try await client.from("roundtable_participants").insert(participant).execute()
    }
    
    func leaveRoundtable(roundtableId: UUID) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        try await client.from("roundtable_participants")
            .delete()
            .eq("roundtable_id", value: roundtableId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
    
    func sendMessage(roundtableId: UUID, content: String) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        let message = [
            "roundtable_id": roundtableId.uuidString,
            "user_id": userId.uuidString,
            "content": content,
            "type": "text"
        ]
        
        try await client.from("roundtable_messages").insert(message).execute()
    }
}
