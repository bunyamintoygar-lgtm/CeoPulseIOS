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
        opinions = [
            Opinion(
                authorName: "Zeynep K.",
                authorTitle: "İş Geliştirme Yöneticisi",
                authorAvatar: nil,
                question: "Hibrit çalışma modelinde ekip bağlılığını artırmak için sizin en etkili yöntemleriniz nelerdir?",
                status: .open,
                category: "Liderlik & Strateji",
                timeAgo: "2 saat önce",
                viewCount: 128,
                responseCount: 15,
                saveCount: 4,
                isBookmarked: true
            ),
            Opinion(
                authorName: "Mehmet A.",
                authorTitle: "Ürün Yöneticisi",
                authorAvatar: nil,
                question: "Yapay zeka araçlarını iş süreçlerine entegre ederken dikkat edilmesi gereken en kritik noktalar nelerdir?",
                status: .open,
                category: "Teknoloji & İnovasyon",
                timeAgo: "5 saat önce",
                viewCount: 96,
                responseCount: 11,
                saveCount: 3,
                isBookmarked: false
            ),
            Opinion(
                authorName: "Ayşe T.",
                authorTitle: "Finansal Analist",
                authorAvatar: nil,
                question: "2025 ikinci yarısında yatırımcılar için öne çıkacak sektörler sizce hangileri olacak?",
                status: .answered,
                category: "Finans & Yatırım",
                timeAgo: "1 gün önce",
                viewCount: 210,
                responseCount: 23,
                saveCount: 7,
                isBookmarked: true
            )
        ]
    }
    
    var filteredOpinions: [Opinion] {
        // Simple search filtering
        if searchText.isEmpty {
            return opinions
        }
        return opinions.filter { $0.question.localizedCaseInsensitiveContains(searchText) }
    }
}
