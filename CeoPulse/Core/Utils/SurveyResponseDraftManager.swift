import Foundation

class SurveyResponseDraftManager {
    static let shared = SurveyResponseDraftManager()
    private let prefix = "survey_response_draft_"
    
    struct ResponseDraft: Codable {
        let surveyId: UUID
        let answers: [UUID: Set<UUID>]
        let lastQuestionIndex: Int
        let timestamp: Date
    }
    
    func saveDraft(surveyId: UUID, answers: [UUID: Set<UUID>], lastIndex: Int) {
        let draft = ResponseDraft(
            surveyId: surveyId,
            answers: answers,
            lastQuestionIndex: lastIndex,
            timestamp: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(encoded, forKey: key(for: surveyId))
        }
    }
    
    func loadDraft(for surveyId: UUID) -> ResponseDraft? {
        if let data = UserDefaults.standard.data(forKey: key(for: surveyId)),
           let decoded = try? JSONDecoder().decode(ResponseDraft.self, from: data) {
            return decoded
        }
        return nil
    }
    
    func clearDraft(for surveyId: UUID) {
        UserDefaults.standard.removeObject(forKey: key(for: surveyId))
    }
    
    func hasDraft(for surveyId: UUID) -> Bool {
        return UserDefaults.standard.object(forKey: key(for: surveyId)) != nil
    }
    
    private func key(for surveyId: UUID) -> String {
        return "\(prefix)\(surveyId.uuidString)"
    }
}
