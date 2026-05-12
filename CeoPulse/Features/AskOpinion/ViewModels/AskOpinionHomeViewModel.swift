import Foundation
import SwiftUI
import Combine

class AskOpinionHomeViewModel: NSObject, ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0 // 0: Tüm Sorular, 1: Yanıtladıklarım, 2: Takip Ettiklerim
    @Published var opinions: [Opinion] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = AskOpinionService.shared
    
    override init() {
        super.init()
        Task {
            await fetchOpinions()
        }
    }
    
    @MainActor
    func fetchOpinions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            opinions = try await service.fetchOpinions()
        } catch {
            print("Error fetching opinions: \(error)")
            errorMessage = "Veriler yüklenirken bir hata oluştu."
        }
        
        isLoading = false
    }
    
    var filteredOpinions: [Opinion] {
        // Simple search filtering
        var result = opinions
        
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Tab filtering could be added here later
        
        return result
    }
}
