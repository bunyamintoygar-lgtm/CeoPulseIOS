import Foundation
import SwiftUI
import Combine

class AskOpinionHomeViewModel: NSObject, ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0 // 0: Tüm Sorular, 1: Yanıtladıklarım, 2: Takip Ettiklerim
    @Published var opinions: [Opinion] = []
    @Published var isLoading: Bool = false
    @Published var isFetchingMore: Bool = false
    @Published var errorMessage: String?
    
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    private var canLoadMore: Bool = true
    
    private let service = AskOpinionService.shared
    
    override init() {
        super.init()
        Task {
            await refreshOpinions()
        }
    }
    
    @MainActor
    func refreshOpinions() async {
        currentPage = 0
        canLoadMore = true
        isLoading = true
        errorMessage = nil
        
        do {
            opinions = try await service.fetchOpinions(page: currentPage, pageSize: pageSize)
            if opinions.count < pageSize {
                canLoadMore = false
            }
        } catch {
            print("Error fetching opinions: \(error)")
            errorMessage = "Veriler yüklenirken bir hata oluştu."
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchMoreOpinionsIfNeeded(currentOpinion: Opinion) async {
        guard canLoadMore && !isFetchingMore && !isLoading && searchText.isEmpty else { return }
        
        // Load more when user is near the end (e.g., 3 items from bottom)
        let thresholdIndex = opinions.index(opinions.endIndex, offsetBy: -3)
        if opinions.firstIndex(where: { $0.id == currentOpinion.id }) == thresholdIndex {
            await loadMoreOpinions()
        }
    }
    
    @MainActor
    private func loadMoreOpinions() async {
        isFetchingMore = true
        currentPage += 1
        
        do {
            let nextBatch = try await service.fetchOpinions(page: currentPage, pageSize: pageSize)
            if nextBatch.isEmpty {
                canLoadMore = false
            } else {
                opinions.append(contentsOf: nextBatch)
                if nextBatch.count < pageSize {
                    canLoadMore = false
                }
            }
        } catch {
            print("Error loading more: \(error)")
            currentPage -= 1 // Revert page on error
        }
        
        isFetchingMore = false
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
