import Foundation

struct Opinion: Identifiable {
    let id: UUID = UUID()
    let authorName: String
    let authorTitle: String
    let authorAvatar: String?
    let question: String
    let status: OpinionStatus
    let category: String
    let timeAgo: String
    let viewCount: Int
    let responseCount: Int
    let saveCount: Int
    let isBookmarked: Bool
}

enum OpinionStatus {
    case open
    case answered
    case closed
    
    var title: String {
        switch self {
        case .open: return "Açık"
        case .answered: return "Yanıtlandı"
        case .closed: return "Kapandı"
        }
    }
}
