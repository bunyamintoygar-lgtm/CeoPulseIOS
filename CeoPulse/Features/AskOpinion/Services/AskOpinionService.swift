import Foundation
import Supabase

class AskOpinionService {
    static let shared = AskOpinionService()
    private let client = SupabaseManager.shared.client
    
    func createOpinion(_ opinion: Opinion) async throws {
        // Prepare data for Supabase
        let data: [String: AnyHashable] = [
            "author_id": opinion.authorId.uuidString,
            "title": opinion.title,
            "description": opinion.description,
            "category": opinion.category,
            "type": opinion.type,
            "target_audience": opinion.targetAudience,
            "privacy_level": opinion.privacyLevel,
            "attachments": try? JSONEncoder().encode(opinion.attachments),
            "status": "open"
        ]
        
        try await client
            .from("ask_opinions")
            .insert(data)
            .execute()
    }
    
    func fetchOpinions() async throws -> [Opinion] {
        let opinions: [Opinion] = try await client
            .from("ask_opinions")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return opinions
    }
}
