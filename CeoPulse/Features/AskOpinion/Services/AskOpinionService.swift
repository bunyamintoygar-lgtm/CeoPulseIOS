import Foundation
import Supabase

// Database Transfer Objects (DTOs) for Supabase compatibility
struct OpinionDTO: Codable {
    let id: UUID?
    let author_id: UUID
    let title: String
    let description: String
    let category: String
    let type: Int
    let target_audience: Int
    let privacy_level: Int
    let attachments: [OpinionAttachment]
    let status: String
    let view_count: Int?
    let response_count: Int?
    let like_count: Int?
    let created_at: Date?
    
    // Join from profiles table
    let profiles: ProfileDTO?
}

struct ProfileDTO: Codable {
    let first_name: String?
    let last_name: String?
    let avatar_url: String?
    let position: String?
}

struct OpinionResponseDTO: Codable {
    let id: UUID?
    let opinion_id: UUID
    let author_id: UUID
    let content: String
    let is_best_response: Bool?
    let is_anonymous: Bool?
    let like_count: Int?
    let comment_count: Int?
    let attachments: [OpinionAttachment]?
    let created_at: Date?
    
    let profiles: ProfileDTO?
}

class AskOpinionService {
    static let shared = AskOpinionService()
    private let client = SupabaseManager.shared.client
    
    func createOpinion(_ opinion: Opinion) async throws {
        let dto = OpinionDTO(
            id: nil,
            author_id: opinion.authorId,
            title: opinion.title,
            description: opinion.description,
            category: opinion.category,
            type: opinion.type,
            target_audience: opinion.targetAudience,
            privacy_level: opinion.privacyLevel,
            attachments: opinion.attachments,
            status: opinion.status.rawValue,
            view_count: 0,
            response_count: 0,
            like_count: 0,
            created_at: nil,
            profiles: nil
        )
        
        try await client
            .from("ask_opinions")
            .insert(dto)
            .execute()
    }
    
    func fetchOpinions(page: Int = 0, pageSize: Int = 10, query: String? = nil, categoryId: String? = nil) async throws -> [Opinion] {
        let from = page * pageSize
        let to = from + pageSize - 1
        
        var request = client
            .from("ask_opinions")
            .select("*, profiles(*)")
            
        if let query = query, !query.isEmpty {
            request = request.or("title.ilike.%\(query)%,description.ilike.%\(query)%")
        }
        
        if let categoryId = categoryId {
            request = request.eq("category", value: categoryId)
        }
        
        let response: [OpinionDTO] = try await request
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
        
        // Map DTOs to Domain Models
        return response.map { dto in
            let firstName = dto.profiles?.first_name ?? "Anonim"
            let lastName = dto.profiles?.last_name ?? ""
            let lastInitial = lastName.isEmpty ? "" : String(lastName.prefix(1)) + "."
            let formattedName = "\(firstName) \(lastInitial)".trimmingCharacters(in: .whitespaces)
            
            return Opinion(
                id: dto.id ?? UUID(),
                authorId: dto.author_id,
                authorName: formattedName,
                authorTitle: dto.profiles?.position ?? "CEO",
                authorAvatar: dto.profiles?.avatar_url,
                title: dto.title,
                description: dto.description,
                status: OpinionStatus(rawValue: dto.status) ?? .open,
                category: dto.category,
                type: dto.type,
                targetAudience: dto.target_audience,
                privacyLevel: dto.privacy_level,
                attachments: dto.attachments,
                viewCount: dto.view_count ?? 0,
                responseCount: dto.response_count ?? 0,
                likeCount: dto.like_count ?? 0,
                createdAt: dto.created_at ?? Date()
            )
        }
    }
    func fetchResponses(opinionId: UUID, currentUserId: UUID? = nil) async throws -> [OpinionResponse] {
        let response: [OpinionResponseDTO] = try await client
            .from("opinion_responses")
            .select("*, profiles(*)")
            .eq("opinion_id", value: opinionId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        var likedResponseIds: Set<UUID> = []
        if let userId = currentUserId {
            do {
                let likes: [[String: UUID]] = try await client
                    .from("opinion_response_likes")
                    .select("response_id")
                    .eq("user_id", value: userId)
                    .execute()
                    .value
                likedResponseIds = Set(likes.compactMap { $0["response_id"] })
            } catch {
                print("Error fetching likes: \(error)")
            }
        }
        
        return response.map { dto in
            let firstName = dto.profiles?.first_name ?? "Gizli"
            let lastName = dto.profiles?.last_name ?? ""
            let lastInitial = lastName.isEmpty ? "" : String(lastName.prefix(1)) + "."
            let formattedName = "\(firstName) \(lastInitial)".trimmingCharacters(in: .whitespaces)
            
            return OpinionResponse(
                id: dto.id ?? UUID(),
                opinionId: dto.opinion_id,
                authorId: dto.author_id,
                authorName: dto.is_anonymous == true ? "Gizli Kullanıcı" : formattedName,
                authorTitle: dto.is_anonymous == true ? "CEO Pulse Üyesi" : (dto.profiles?.position ?? "CEO"),
                authorAvatar: dto.is_anonymous == true ? nil : dto.profiles?.avatar_url,
                content: dto.content,
                likeCount: dto.like_count ?? 0,
                commentCount: dto.comment_count ?? 0,
                isBestResponse: dto.is_best_response ?? false,
                isAnonymous: dto.is_anonymous ?? false,
                isLiked: likedResponseIds.contains(dto.id ?? UUID()),
                attachments: dto.attachments ?? [],
                createdAt: dto.created_at ?? Date()
            )
        }
    }
    
    func toggleLikeResponse(responseId: UUID, userId: UUID, isLiked: Bool) async throws {
        if isLiked {
            try await client
                .from("opinion_response_likes")
                .insert(["user_id": userId, "response_id": responseId])
                .execute()
        } else {
            try await client
                .from("opinion_response_likes")
                .delete()
                .eq("user_id", value: userId)
                .eq("response_id", value: responseId)
                .execute()
        }
    }
    
    func incrementViewCount(opinionId: UUID) async throws {
        do {
            try await client
                .rpc("increment_opinion_view_count", params: ["op_id": opinionId])
                .execute()
            print("DEBUG: View count incremented for \(opinionId)")
        } catch {
            print("ERROR: Failed to increment view count: \(error)")
            throw error
        }
    }
    
    func createResponse(opinionId: UUID, authorId: UUID, content: String, isAnonymous: Bool, attachments: [OpinionAttachment] = []) async throws -> OpinionResponse {
        let dto = OpinionResponseDTO(
            id: nil,
            opinion_id: opinionId,
            author_id: authorId,
            content: content,
            is_best_response: false,
            is_anonymous: isAnonymous,
            like_count: 0,
            comment_count: 0,
            attachments: attachments,
            created_at: nil,
            profiles: nil
        )
        
        let saved: OpinionResponseDTO = try await client
            .from("opinion_responses")
            .insert(dto)
            .select("*, profiles(*)")
            .single()
            .execute()
            .value
            
        // Map back to domain model
        let firstName = saved.profiles?.first_name ?? "Gizli"
        let lastName = saved.profiles?.last_name ?? ""
        let formattedName = "\(firstName) \(lastName.prefix(1)).".trimmingCharacters(in: .whitespaces)
        
        return OpinionResponse(
            id: saved.id ?? UUID(),
            opinionId: saved.opinion_id,
            authorId: saved.author_id,
            authorName: saved.is_anonymous == true ? "Gizli Kullanıcı" : formattedName,
            authorTitle: saved.is_anonymous == true ? "CEO Pulse Üyesi" : (saved.profiles?.position ?? "CEO"),
            authorAvatar: saved.is_anonymous == true ? nil : saved.profiles?.avatar_url,
            content: saved.content,
            likeCount: saved.like_count ?? 0,
            commentCount: saved.comment_count ?? 0,
            isBestResponse: saved.is_best_response ?? false,
            isAnonymous: saved.is_anonymous ?? false,
            createdAt: saved.created_at ?? Date()
        )
    }
    
    func updateResponse(responseId: UUID, content: String) async throws {
        try await client
            .from("opinion_responses")
            .update(["content": content])
            .eq("id", value: responseId)
            .execute()
    }
    
    func deleteResponse(responseId: UUID) async throws {
        try await client
            .from("opinion_responses")
            .delete()
            .eq("id", value: responseId)
            .execute()
    }
}
