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
    let attachments: String // JSON string
    let status: String
    let view_count: Int?
    let response_count: Int?
    let like_count: Int?
    let created_at: Date?
}

class AskOpinionService {
    static let shared = AskOpinionService()
    private let client = SupabaseManager.shared.client
    
    func createOpinion(_ opinion: Opinion) async throws {
        // Convert attachments to JSON string
        let attachmentsData = try JSONEncoder().encode(opinion.attachments)
        let attachmentsString = String(data: attachmentsData, encoding: .utf8) ?? "[]"
        
        let dto = OpinionDTO(
            id: nil,
            author_id: opinion.authorId,
            title: opinion.title,
            description: opinion.description,
            category: opinion.category,
            type: opinion.type,
            target_audience: opinion.targetAudience,
            privacy_level: opinion.privacyLevel,
            attachments: attachmentsString,
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
    
    func fetchOpinions() async throws -> [Opinion] {
        let response: [OpinionDTO] = try await client
            .from("ask_opinions")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        
        // Map DTOs to Domain Models
        return response.map { dto in
            // Parse attachments JSON string
            let attachmentsData = dto.attachments.data(using: .utf8) ?? Data()
            let attachments = (try? JSONDecoder().decode([OpinionAttachment].self, from: attachmentsData)) ?? []
            
            return Opinion(
                id: dto.id ?? UUID(),
                authorId: dto.author_id,
                authorName: "Yükleniyor...", // This would normally come from a profile join
                authorTitle: "CEO",
                authorAvatar: nil,
                title: dto.title,
                description: dto.description,
                status: OpinionStatus(rawValue: dto.status) ?? .open,
                category: dto.category,
                type: dto.type,
                targetAudience: dto.target_audience,
                privacyLevel: dto.privacy_level,
                attachments: attachments,
                viewCount: dto.view_count ?? 0,
                responseCount: dto.response_count ?? 0,
                likeCount: dto.like_count ?? 0,
                createdAt: dto.created_at ?? Date()
            )
        }
    }
}
