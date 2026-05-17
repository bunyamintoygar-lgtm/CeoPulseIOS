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
            query = query.eq("moderator_id", value: moderatorId.uuidString.lowercased())
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
            .eq("roundtable_id", value: roundtableId.uuidString.lowercased())
            .execute()
            .value
        return participants
    }
    
    func fetchMessages(roundtableId: UUID) async throws -> [RoundtableMessage] {
        let messages: [RoundtableMessage] = try await client.from("roundtable_messages")
            .select()
            .eq("roundtable_id", value: roundtableId.uuidString.lowercased())
            .order("created_at", ascending: true)
            .execute()
            .value
        return messages
    }
    
    // MARK: - Actions
    
    func joinRoundtable(roundtableId: UUID, role: RoundtableRole = .listener, agoraUid: UInt? = nil) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        struct ParticipantInsert: Encodable {
            let roundtable_id: String
            let user_id: String
            let role: String
            let agora_uid: Int?
        }
        
        let participant = ParticipantInsert(
            roundtable_id: roundtableId.uuidString.lowercased(),
            user_id: userId.uuidString.lowercased(),
            role: role.rawValue,
            agora_uid: agoraUid.map { Int($0 & 0x7FFFFFFF) }  // safe UInt→Int, always positive

        )
        
        try await client.from("roundtable_participants").insert(participant).execute()
    }
    
    func updateAgoraUid(roundtableId: UUID, agoraUid: UInt) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        try await client.from("roundtable_participants")
            .update(["agora_uid": agoraUid])
            .eq("roundtable_id", value: roundtableId.uuidString.lowercased())
            .eq("user_id", value: userId.uuidString.lowercased())
            .execute()
    }
    
    func leaveRoundtable(roundtableId: UUID) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        try await client.from("roundtable_participants")
            .delete()
            .eq("roundtable_id", value: roundtableId.uuidString.lowercased())
            .eq("user_id", value: userId.uuidString.lowercased())
            .execute()
    }
    
    func sendMessage(roundtableId: UUID, content: String) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        let message = [
            "roundtable_id": roundtableId.uuidString.lowercased(),
            "user_id": userId.uuidString.lowercased(),
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
            .eq("roundtable_id", value: roundtableId.uuidString.lowercased())
            .eq("user_id", value: userId.uuidString.lowercased())
            .execute()
    }
    
    func updateRole(roundtableId: UUID, userId: UUID, role: RoundtableRole) async throws {
        struct UpdateData: Encodable {
            let role: String
            let is_requesting_floor: Bool
        }
        
        try await client.from("roundtable_participants")
            .update(UpdateData(role: role.rawValue, is_requesting_floor: false))
            .eq("roundtable_id", value: roundtableId.uuidString.lowercased())
            .eq("user_id", value: userId.uuidString.lowercased())
            .execute()
    }
    
    func updateParticipant(id: UUID, role: RoundtableRole, isRequestingFloor: Bool) async throws {
        struct UpdateData: Encodable {
            let role: String
            let is_requesting_floor: Bool
        }
        
        try await client.from("roundtable_participants")
            .update(UpdateData(role: role.rawValue, is_requesting_floor: isRequestingFloor))
            .eq("id", value: id.uuidString.lowercased())
            .execute()
    }
    
    func fetchTranscripts(roundtableId: UUID) async throws -> [RoundtableTranscript] {
        let transcripts: [RoundtableTranscript] = try await client.from("roundtable_transcripts")
            .select()
            .eq("roundtable_id", value: roundtableId.uuidString.lowercased())
            .order("created_at", ascending: true)
            .execute()
            .value
        return transcripts
    }
    
    func sendTranscript(roundtableId: UUID, userId: UUID, content: String) async throws {
        let data = [
            "roundtable_id": roundtableId.uuidString.lowercased(),
            "user_id": userId.uuidString.lowercased(),
            "content": content
        ]
        
        try await client.from("roundtable_transcripts").insert(data).execute()
    }
    
    // Saves an STT-captured transcript — userId is optional (bot may not know the speaker)
    func saveTranscript(roundtableId: UUID, content: String, userId: UUID?) async throws {
        var data: [String: String] = [
            "roundtable_id": roundtableId.uuidString.lowercased(),
            "content": content
        ]
        if let userId = userId {
            data["user_id"] = userId.uuidString.lowercased()
        }
        try await client.from("roundtable_transcripts").insert(data).execute()
    }
    
    func updateCurrentSpeaker(roundtableId: UUID, userId: UUID?) async throws {
        let data: [String: String?] = ["current_speaker_id": userId?.uuidString.lowercased()]
        
        try await client.from("roundtables")
            .update(data)
            .eq("id", value: roundtableId.uuidString.lowercased())
            .execute()
    }
    
    func updateParticipantMuteState(id: UUID, isMuted: Bool) async throws {
        struct UpdateData: Encodable {
            let is_muted: Bool
        }
        
        try await client.from("roundtable_participants")
            .update(UpdateData(is_muted: isMuted))
            .eq("id", value: id.uuidString.lowercased())
            .execute()
    }
}
