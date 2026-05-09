import Foundation
import Supabase

class SurveyService {
    static let shared = SurveyService()
    private let client = SupabaseManager.shared.client
    
    // MARK: - Fetch Methods
    
    func searchSurveys(query: String, page: Int = 0, pageSize: Int = 15) async throws -> [Survey] {
        let from = page * pageSize
        let to = from + pageSize - 1
        
        // PostgreSQL ilike automatically handles most case-insensitive scenarios.
        // For strict Turkish support, we could use custom RPC, but ilike is generally sufficient 
        // if the database is UTF-8. We'll also lower-case the query for safety.
        let surveys: [Survey] = try await client
            .from("surveys")
            .select()
            .eq("status", value: "active")
            .ilike("title", pattern: "%\(query)%")
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
        return surveys
    }
    
    func fetchSurveys(page: Int = 0, pageSize: Int = 15) async throws -> [Survey] {
        let from = page * pageSize
        let to = from + pageSize - 1
        
        let surveys: [Survey] = try await client
            .from("surveys")
            .select()
            .eq("status", value: "active")
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
        return surveys
    }
    
    func fetchQuestions(for surveyId: UUID) async throws -> [SurveyQuestion] {
        let questions: [SurveyQuestion] = try await client
            .from("survey_questions")
            .select()
            .eq("survey_id", value: surveyId)
            .order("order", ascending: true)
            .execute()
            .value
        return questions
    }
    
    func fetchOptions(for questionId: UUID) async throws -> [SurveyOption] {
        let options: [SurveyOption] = try await client
            .from("survey_options")
            .select()
            .eq("question_id", value: questionId)
            .order("order", ascending: true)
            .execute()
            .value
        return options
    }
    
    func fetchParticipationCount(for surveyId: UUID) async throws -> Int {
        let response = try await client
            .from("survey_responses")
            .select("user_id", head: true, count: .exact)
            .eq("survey_id", value: surveyId)
            .execute()
        
        return response.count ?? 0
    }
    
    func fetchResults(for surveyId: UUID) async throws -> [UUID: Int] {
        struct ResponseItem: Codable {
            let option_id: UUID
        }
        
        // Fetch all responses for the survey
        let responses: [ResponseItem] = try await client
            .from("survey_responses")
            .select("option_id")
            .eq("survey_id", value: surveyId)
            .execute()
            .value
        
        // Count occurrences of each option_id
        var results: [UUID: Int] = [:]
        for response in responses {
            results[response.option_id, default: 0] += 1
        }
        return results
    }
    
    // MARK: - Create Methods
    
    func createSurvey(survey: Survey, questions: [SurveyQuestion], options: [UUID: [SurveyOption]]) async throws {
        // 1. Insert Survey
        try await client
            .from("surveys")
            .insert(survey)
            .execute()
        
        // 2. Insert Questions
        try await client
            .from("survey_questions")
            .insert(questions)
            .execute()
        
        // 3. Insert Options
        var allOptions: [SurveyOption] = []
        for questionId in options.keys {
            if let qOptions = options[questionId] {
                allOptions.append(contentsOf: qOptions)
            }
        }
        
        if !allOptions.isEmpty {
            try await client
                .from("survey_options")
                .insert(allOptions)
                .execute()
        }
    }
    
    // MARK: - Vote Methods
    
    func submitVote(surveyId: UUID, answers: [UUID: Set<UUID>]) async throws {
        let userId = try await getCurrentUserId()
        
        struct VoteEntry: Encodable {
            let survey_id: UUID
            let question_id: UUID
            let option_id: UUID
            let user_id: UUID
        }
        
        var voteEntries: [VoteEntry] = []
        
        for (questionId, optionIds) in answers {
            for optionId in optionIds {
                voteEntries.append(VoteEntry(
                    survey_id: surveyId,
                    question_id: questionId,
                    option_id: optionId,
                    user_id: userId
                ))
            }
        }
        
        if !voteEntries.isEmpty {
            try await client
                .from("survey_responses")
                .upsert(voteEntries, onConflict: "question_id,user_id")
                .execute()
        }
    }
    
    private func getCurrentUserId() async throws -> UUID {
        // This is a placeholder. Real implementation should get ID from Auth
        let session = try await client.auth.session
        return session.user.id
    }
}
