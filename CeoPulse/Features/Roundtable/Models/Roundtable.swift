import Foundation
import SwiftUI

struct Roundtable: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let category: String
    var status: RoundtableStatus
    let startTime: Date
    let endTime: Date?
    let imageUrl: String?
    let moderatorId: UUID?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, category, status
        case startTime = "start_time"
        case endTime = "end_time"
        case imageUrl = "image_url"
        case moderatorId = "moderator_id"
        case createdAt = "created_at"
    }
}

enum RoundtableStatus: String, Codable {
    case upcoming = "upcoming"
    case active = "active"
    case completed = "completed"
    case archived = "archived"
    
    var title: String {
        switch self {
        case .upcoming: return "rt_status_upcoming".localized()
        case .active: return "rt_status_active".localized()
        case .completed: return "rt_status_completed".localized()
        case .archived: return "rt_status_archived".localized()
        }
    }
    
    var color: Color {
        switch self {
        case .upcoming: return .orange
        case .active: return .green
        case .completed: return .blue
        case .archived: return .gray
        }
    }
}

struct RoundtableParticipant: Identifiable, Codable {
    let id: UUID
    let roundtableId: UUID
    let userId: UUID
    var role: RoundtableRole
    var isMuted: Bool
    let joinedAt: Date
    
    // Joined profile data (for UI)
    var userName: String?
    var userTitle: String?
    var userAvatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case roundtableId = "roundtable_id"
        case userId = "user_id"
        case role
        case isMuted = "is_muted"
        case joinedAt = "joined_at"
    }
}

enum RoundtableRole: String, Codable {
    case moderator = "moderator"
    case speaker = "speaker"
    case listener = "listener"
    
    var title: String {
        switch self {
        case .moderator: return "rt_role_moderator".localized()
        case .speaker: return "rt_role_speaker".localized()
        case .listener: return "rt_role_listener".localized()
        }
    }
    
    var color: Color {
        switch self {
        case .moderator: return .purple
        case .speaker: return .blue
        case .listener: return .gray
        }
    }
}

struct RoundtableMessage: Identifiable, Codable {
    let id: UUID
    let roundtableId: UUID
    let userId: UUID
    let content: String
    let type: String // text, system, insight
    let createdAt: Date
    
    // Joined profile data (for UI)
    var userName: String?
    var userTitle: String?
    var userAvatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case roundtableId = "roundtable_id"
        case userId = "user_id"
        case content, type
        case createdAt = "created_at"
    }
}

extension Roundtable {
    static var mock: Roundtable {
        Roundtable(
            id: UUID(),
            title: "Yapay Zeka Çağında Liderlik: Stratejilerimiz Nasıl Değişmeli?",
            description: "AI dönüşümü, liderlik yetkinliklerini ve organizasyon kültürünü nasıl yeniden şekillendiriyor?",
            category: "Teknoloji",
            status: .active,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            imageUrl: "ai_meeting",
            moderatorId: UUID(),
            createdAt: Date()
        )
    }
}
