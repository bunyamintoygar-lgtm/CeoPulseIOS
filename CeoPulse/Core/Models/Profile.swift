import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    var first_name: String?
    var last_name: String?
    var position: String?
    var company: String?
    var company_size: String?
    var duration: String?
    var sector: String?
    var skills: [String]?
    var bio: String?
    var avatar_url: String?
    var is_public: Bool?
    var updated_at: Date?
    
    var fullName: String {
        "\(first_name ?? "") \(last_name ?? "")".trimmingCharacters(in: .whitespaces)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, first_name, last_name, position, company, company_size, duration, sector, skills, bio, avatar_url, is_public, updated_at
    }
}
