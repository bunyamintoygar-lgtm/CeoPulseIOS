import Foundation
import Combine
import Supabase

class AIInsightsViewModel: ObservableObject {
    @Published var insights: [AIInsight] = []
    @Published var selectedCategory: String = "Tümü"
    @Published var searchText: String = "" // Yeni arama metni
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    var filteredInsights: [AIInsight] {
        var filtered = insights
        
        // 1. Kategori Filtreleme
        if selectedCategory != "Tümü" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // 2. Arama Filtreleme (Türkçe karakter duyarlı)
        if !searchText.isEmpty {
            filtered = filtered.filter { insight in
                let titleMatch = insight.title.localizedCaseInsensitiveContains(searchText)
                let subtitleMatch = (insight.subtitle ?? "").localizedCaseInsensitiveContains(searchText)
                return titleMatch || subtitleMatch
            }
        }
        
        return filtered
    }
    
    var featuredInsight: AIInsight? {
        insights.first // For now, the most recent one is featured
    }
    
    @MainActor
    func fetchInsights() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedInsights: [AIInsight] = try await client
                .from("ai_insights")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.insights = fetchedInsights
            isLoading = false
        } catch {
            print("Error fetching insights: \(error)")
            self.errorMessage = "İçgörüler yüklenirken bir hata oluştu."
            isLoading = false
        }
    }
}
