import Foundation

struct Survey: Identifiable, Codable {
    let id: UUID
    let creatorId: UUID
    let title: String
    let description: String?
    let categoryId: String?
    let coverImageUrl: String?
    let targetAudience: String
    let status: SurveyStatus
    let rejectionReason: String?
    let startDate: Date
    let endDate: Date?
    let isAnonymous: Bool
    let resultVisibility: ResultVisibility
    let allowEditResponses: Bool
    let participationLimit: Int?
    let createdAt: Date
    let language: String?
    
    enum SurveyStatus: String, Codable {
        case active, completed, draft, archived, rejected
    }
    
    enum ResultVisibility: String, Codable {
        case immediate, after_closed, never
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId = "creator_id"
        case title
        case description
        case categoryId = "category_id"
        case coverImageUrl = "cover_image_url"
        case targetAudience = "target_audience"
        case status
        case rejectionReason = "rejection_reason"
        case startDate = "start_date"
        case endDate = "end_date"
        case isAnonymous = "is_anonymous"
        case resultVisibility = "result_visibility"
        case allowEditResponses = "allow_edit_responses"
        case participationLimit = "participation_limit"
        case createdAt = "created_at"
        case language
    }
}

struct SurveyCategory: Identifiable, Codable, Equatable {
    let id: String
    let tr: String
    let en: String
    let icon: String?
    
    var name: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "tr"
        return lang == "en" ? en : tr
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case tr
        case en
        case icon
    }
}

struct SurveyQuestion: Identifiable, Codable {
    let id: UUID
    let surveyId: UUID
    let questionText: String
    let questionType: QuestionType
    let isRequired: Bool
    let maxSelections: Int
    let order: Int
    
    enum QuestionType: String, Codable {
        case singleChoice = "single_choice"
        case multipleChoice = "multiple_choice"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case surveyId = "survey_id"
        case questionText = "question_text"
        case questionType = "question_type"
        case isRequired = "is_required"
        case maxSelections = "max_selections"
        case order
    }
}

struct SurveyOption: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    let optionText: String
    let order: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case optionText = "option_text"
        case order
    }
}

struct SurveyWithDetails: Identifiable {
    var id: UUID { survey.id }
    let survey: Survey
    let questions: [QuestionWithSharedOptions]
    var participationRate: Double = 0.0
    var totalVotes: Int = 0
}

struct QuestionWithSharedOptions: Identifiable {
    let id: UUID = UUID()
    let question: SurveyQuestion
    let options: [SurveyOption]
}
