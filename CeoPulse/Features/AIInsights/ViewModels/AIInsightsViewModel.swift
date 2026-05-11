import Foundation
import Combine
import Supabase

class AIInsightsViewModel: ObservableObject {
    @Published var insights: [AIInsight] = []
    @Published var selectedCategory: String = "Tümü"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    var filteredInsights: [AIInsight] {
        if selectedCategory == "Tümü" {
            return insights
        }
        return insights.filter { $0.category == selectedCategory }
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
