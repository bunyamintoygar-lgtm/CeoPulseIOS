import Foundation
import Supabase
import PostgREST
import Realtime

class RoundtableService {
    static let shared = RoundtableService()
    private let client = SupabaseManager.shared.client
    
    private init() {}
    
    // MARK: - Fetching
    
    func fetchRoundtables(status: RoundtableStatus? = nil, category: String? = nil, searchText: String? = nil, moderatorId: UUID? = nil) async throws -> [Roundtable] {
        var query = client.from("roundtables").select()
        
        if let status = status {
            query = query.eq("status", value: status.rawValue)
        }
        
        if let category = category, category != "Tümü" {
            query = query.eq("category", value: category)
        }
        
        if let moderatorId = moderatorId {
            query = query.eq("moderator_id", value: moderatorId.uuidString)
        }
        
        if let searchText = searchText, !searchText.isEmpty {
            query = query.ilike("title", pattern: "%\(searchText)%")
        }
        
        let roundtables: [Roundtable] = try await query.order("start_time", ascending: true).execute().value
        return roundtables
    }
    
    func fetchParticipants(roundtableId: UUID) async throws -> [RoundtableParticipant] {
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
    
    func requestFloor(roundtableId: UUID, isRequesting: Bool) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        try await client.from("roundtable_participants")
            .update(["is_requesting_floor": isRequesting])
            .eq("roundtable_id", value: roundtableId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
    
    func updateRole(roundtableId: UUID, userId: UUID, role: RoundtableRole) async throws {
        struct UpdateData: Encodable {
            let role: String
            let is_requesting_floor: Bool
        }
        
        print("DEBUG: updateRole starting for user \(userId) to role \(role.rawValue)")
        
        let response = try await client.from("roundtable_participants")
            .update(UpdateData(role: role.rawValue, is_requesting_floor: false))
            .eq("roundtable_id", value: roundtableId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        print("DEBUG: updateRole finished with status: \(response.status)")
    }
    
    func updateCurrentSpeaker(roundtableId: UUID, userId: UUID?) async throws {
        let data: [String: String?] = ["current_speaker_id": userId?.uuidString]
        
        try await client.from("roundtables")
            .update(data)
            .eq("id", value: roundtableId.uuidString)
            .execute()
    }
}
