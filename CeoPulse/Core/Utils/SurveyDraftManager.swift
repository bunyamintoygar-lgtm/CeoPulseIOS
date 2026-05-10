import Foundation
import Combine

class SurveyDraftManager: ObservableObject {
    static let shared = SurveyDraftManager()
    private let draftKey = "survey_draft_data"
    
    struct DraftData: Codable {
        var title: String
        var description: String
        var categoryId: String?
        var targetAudience: String
        var questions: [DraftQuestion]
        var currentStep: Int
        var lastEdited: Date
        
        // Settings
        var hasEndDate: Bool
        var endDate: Date
        var participationLimit: String
        var resultsVisibility: String
        var allowChangeResponse: Bool
        var isRequired: Bool
        var isAnonymous: Bool
    }
    
    func saveDraft(
        title: String, 
        description: String, 
        category: SurveyCategory?, 
        audience: String, 
        questions: [DraftQuestion], 
        step: Int,
        hasEndDate: Bool,
        endDate: Date,
        participationLimit: String,
        resultsVisibility: String,
        allowChangeResponse: Bool,
        isRequired: Bool,
        isAnonymous: Bool
    ) {
        let draft = DraftData(
            title: title,
            description: description,
            categoryId: category?.id,
            targetAudience: audience,
            questions: questions,
            currentStep: step,
            lastEdited: Date(),
            hasEndDate: hasEndDate,
            endDate: endDate,
            participationLimit: participationLimit,
            resultsVisibility: resultsVisibility,
            allowChangeResponse: allowChangeResponse,
            isRequired: isRequired,
            isAnonymous: isAnonymous
        )
        
        do {
            let encoded = try JSONEncoder().encode(draft)
            UserDefaults.standard.set(encoded, forKey: draftKey)
        } catch {
            print("❌ Failed to save survey draft: \(error)")
        }
    }
    
    func loadDraft() -> DraftData? {
        if let data = UserDefaults.standard.data(forKey: draftKey),
           let decoded = try? JSONDecoder().decode(DraftData.self, from: data) {
            return decoded
        }
        return nil
    }
    
    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: draftKey)
    }
    
    func hasDraft() -> Bool {
        return UserDefaults.standard.object(forKey: draftKey) != nil
    }
}
