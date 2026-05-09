import Foundation
import Supabase

class SurveyService {
    static let shared = SurveyService()
    private let client = SupabaseManager.shared.client
    
    // MARK: - Fetch Methods
    
    func fetchSurveys(
        query: String? = nil,
        categoryId: String? = nil,
        page: Int = 0,
        pageSize: Int = 15
    ) async throws -> [Survey] {
        let from = page * pageSize
        let to = from + pageSize - 1
        
        var request = client
            .from("surveys")
            .select()
            .eq("status", value: "active")
        
        if let query = query, !query.isEmpty {
            // Search in title OR description using PostgreSQL ilike
            request = request.or("title.ilike.%\(query)%,description.ilike.%\(query)%")
        }
        
        if let categoryId = categoryId {
            request = request.eq("category_id", value: categoryId)
        }
        
        let surveys: [Survey] = try await request
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
        // Fetch unique user counts for this survey
        struct VoteInfo: Codable { let user_id: UUID }
        let votes: [VoteInfo] = try await client
            .from("survey_responses")
            .select("user_id")
            .eq("survey_id", value: surveyId)
            .execute()
            .value
        
        return Set(votes.map { $0.user_id }).count
    }
    
    func checkIfUserVoted(surveyId: UUID) async throws -> Bool {
        guard let userId = try? await getCurrentUserId() else { return false }
        
        let response = try await client
            .from("survey_responses")
            .select("id", head: true, count: .exact)
            .eq("survey_id", value: surveyId)
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
        
        return (response.count ?? 0) > 0
    }
    
    struct SurveyStats: Codable {
        let totalVotes: Int
        let hasVoted: Bool
    }
    
    func fetchSurveyStats(surveyId: UUID) async throws -> SurveyStats {
        let total = try await fetchParticipationCount(for: surveyId)
        let voted = try await checkIfUserVoted(surveyId: surveyId)
        return SurveyStats(totalVotes: total, hasVoted: voted)
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
            // Get the list of question IDs we are answering
            let questionIds = Array(answers.keys)
            
            // 1. Delete existing responses for these specific questions by this user
            try await client
                .from("survey_responses")
                .delete()
                .eq("user_id", value: userId)
                .in("question_id", values: questionIds)
                .execute()
            
            // 2. Insert new responses
            try await client
                .from("survey_responses")
                .insert(voteEntries)
                .execute()
        }
    }
    
    private func getCurrentUserId() async throws -> UUID {
        // This is a placeholder. Real implementation should get ID from Auth
        let session = try await client.auth.session
        return session.user.id
    }
}
