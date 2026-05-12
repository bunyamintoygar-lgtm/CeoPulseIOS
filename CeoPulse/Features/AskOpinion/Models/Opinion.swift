import Foundation

struct Opinion: Identifiable {
    let id: UUID
    let authorId: UUID
    let authorName: String
    let authorTitle: String
    let authorAvatar: String?
    let title: String
    let description: String
    let status: OpinionStatus
    let category: String
    let type: Int
    let targetAudience: Int
    let privacyLevel: Int
    let attachments: [OpinionAttachment]
    let viewCount: Int
    let responseCount: Int
    let likeCount: Int
    let createdAt: Date
}

struct OpinionResponse: Identifiable {
    let id: UUID
    let opinionId: UUID
    let authorId: UUID
    let authorName: String
    let authorTitle: String
    let authorAvatar: String?
    let content: String
    let likeCount: Int
    let commentCount: Int
    let isBestResponse: Bool
    let isAnonymous: Bool
    let createdAt: Date
}

struct OpinionAttachment: Codable {
    let name: String
    let type: String
    let url: String
}

enum OpinionStatus: String, Codable {
    case open = "open"
    case answered = "answered"
    case closed = "closed"
    
    var title: String {
        switch self {
        case .open: return "Açık"
        case .answered: return "Yanıtlandı"
        case .closed: return "Kapandı"
        }
    }
}
