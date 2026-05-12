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
            created_at: nil
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
}
