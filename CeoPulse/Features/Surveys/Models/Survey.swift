import Foundation

struct Survey: Identifiable, Codable {
    let id: UUID
    let creatorId: UUID
    let title: String
    let description: String?
    let categoryId: UUID?
    let coverImageUrl: String?
    let targetAudience: String
    let status: SurveyStatus
    let startDate: Date
    let endDate: Date?
    let isAnonymous: Bool
    let resultVisibility: ResultVisibility
    let allowEditResponses: Bool
    let participationLimit: Int?
    let createdAt: Date
    
    enum SurveyStatus: String, Codable {
        case active, completed, draft, archived
    }
    
    enum ResultVisibility: String, Codable {
        case immediate, after_closed, never
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
}

struct SurveyOption: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    let optionText: String
    let order: Int
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
