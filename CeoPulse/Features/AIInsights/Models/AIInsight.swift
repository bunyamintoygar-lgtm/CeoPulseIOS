import Foundation

struct AIInsight: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String?
    let category: String
    let readTime: Int
    let content: InsightContent
    let isPremium: Bool
    let imageUrl: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, category, content
        case readTime = "read_time"
        case isPremium = "is_premium"
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }
}

struct InsightContent: Codable {
    let summaryTab: SummaryTab
    let findingsTab: [InsightFinding]
    let analysisTab: AnalysisTab
    let recommendationsTab: [InsightRecommendation]
    
    enum CodingKeys: String, CodingKey {
        case summaryTab = "summary_tab"
        case findingsTab = "findings_tab"
        case analysisTab = "analysis_tab"
        case recommendationsTab = "recommendations_tab"
    }
}

struct SummaryTab: Codable {
    let description: String
    let stats: [InsightStat]
}

struct InsightStat: Codable, Hashable {
    let label: String
    let value: String
    let icon: String
}

struct InsightFinding: Codable, Identifiable {
    var id: String { title }
    let title: String
    let desc: String
    let percentage: Double
    let icon: String
}

struct AnalysisTab: Codable {
    let trends: [InsightTrend]
    let regionalData: [RegionalData]
    
    enum CodingKeys: String, CodingKey {
        case trends
        case regionalData = "regional_data"
    }
}

struct InsightTrend: Codable, Identifiable {
    var id: String { label }
    let label: String
    let points: [Double]
    let color: String
}

struct RegionalData: Codable, Identifiable {
    var id: String { region }
    let region: String
    let percentage: Double
    let flag: String
}

struct InsightRecommendation: Codable, Identifiable {
    var id: String { title }
    let title: String
    let desc: String
    let impact: String
    let icon: String
}
