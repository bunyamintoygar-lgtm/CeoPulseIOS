import Foundation

struct Opinion: Identifiable {
    let id: UUID
    let authorId: UUID
    let authorName: String
    let authorTitle: String
    let authorAvatar: String?
    let title: String
    let description: String
    var status: OpinionStatus
    let category: String
    let type: Int
    let targetAudience: Int
    let privacyLevel: Int
    let attachments: [OpinionAttachment]
    var viewCount: Int
    var responseCount: Int
    var likeCount: Int
    let createdAt: Date
}

struct OpinionResponse: Identifiable {
    let id: UUID
    let opinionId: UUID
    let authorId: UUID
    let authorName: String
    let authorTitle: String
    let authorAvatar: String?
    var content: String
    var likeCount: Int
    let commentCount: Int
    let isBestResponse: Bool
    let isAnonymous: Bool
    var isLiked: Bool = false
    let attachments: [OpinionAttachment]
    let createdAt: Date
}

struct OpinionAttachment: Codable, Identifiable {
    var id: String { name + type + (url ?? "") }
    let name: String
    let type: String // doc, image, link, survey
    var url: String?
    var survey: OpinionSurveyAttachment?
}

struct OpinionSurveyAttachment: Codable {
    var question: String
    var options: [String]
    var allowMultiple: Bool = false
    var isRequired: Bool = true
}

enum OpinionStatus: String, Codable {
    case open = "open"
    case answered = "answered"
    case closed = "closed"
    
    var title: String {
        switch self {
        case .open: return "ao_status_open".localized()
        case .answered: return "ao_status_answered".localized()
        case .closed: return "ao_status_closed".localized()
        }
    }
}
