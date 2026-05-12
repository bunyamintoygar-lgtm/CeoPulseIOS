import Foundation
import SwiftUI

class AskOpinionHomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0 // 0: Tüm Sorular, 1: Yanıtladıklarım, 2: Takip Ettiklerim
    @Published var opinions: [Opinion] = []
    
    init() {
        loadDummyData()
    }
    
    func loadDummyData() {
        let dummyAuthorId = UUID()
        opinions = [
            Opinion(
                id: UUID(),
                authorId: dummyAuthorId,
                authorName: "Zeynep K.",
                authorTitle: "İş Geliştirme Yöneticisi",
                authorAvatar: nil,
                title: "Hibrit çalışma modelinde ekip bağlılığını artırmak için sizin en etkili yöntemleriniz nelerdir?",
                description: "Küresel CEO Pulse verilerine göre 2026'da yatırım öncelikleri değişiyor.",
                status: .open,
                category: "Liderlik & Strateji",
                type: 0,
                targetAudience: 0,
                privacyLevel: 0,
                attachments: [],
                viewCount: 128,
                responseCount: 15,
                likeCount: 4,
                createdAt: Date().addingTimeInterval(-7200)
            ),
            Opinion(
                id: UUID(),
                authorId: dummyAuthorId,
                authorName: "Mehmet A.",
                authorTitle: "Ürün Yöneticisi",
                authorAvatar: nil,
                title: "Yapay zeka araçlarını iş süreçlerine entegre ederken dikkat edilmesi gereken en kritik noktalar nelerdir?",
                description: "Teknoloji ve inovasyon süreçlerinde AI entegrasyonu.",
                status: .open,
                category: "Teknoloji & İnovasyon",
                type: 0,
                targetAudience: 0,
                privacyLevel: 0,
                attachments: [],
                viewCount: 96,
                responseCount: 11,
                likeCount: 3,
                createdAt: Date().addingTimeInterval(-18000)
            ),
            Opinion(
                id: UUID(),
                authorId: dummyAuthorId,
                authorName: "Ayşe T.",
                authorTitle: "Finansal Analist",
                authorAvatar: nil,
                title: "2025 ikinci yarısında yatırımcılar için öne çıkacak sektörler sizce hangileri olacak?",
                description: "Finans ve yatırım dünyasında gelecek beklentileri.",
                status: .answered,
                category: "Finans & Yatırım",
                type: 0,
                targetAudience: 0,
                privacyLevel: 0,
                attachments: [],
                viewCount: 210,
                responseCount: 23,
                likeCount: 7,
                createdAt: Date().addingTimeInterval(-86400)
            )
        ]
    }
    
    var filteredOpinions: [Opinion] {
        // Simple search filtering
        if searchText.isEmpty {
            return opinions
        }
        return opinions.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}
