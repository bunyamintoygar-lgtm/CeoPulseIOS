import Foundation
import SwiftUI
import Combine

class AskOpinionHomeViewModel: NSObject, ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0 // 0: Tüm Sorular, 1: Yanıtladıklarım, 2: Takip Ettiklerim
    @Published var opinions: [Opinion] = []
    @Published var selectedCategory: String? = nil
    
    @Published var isLoading: Bool = false
    @Published var isFetchingMore: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    private var canLoadMore: Bool = true
    
    private let service = AskOpinionService.shared
    
    override init() {
        super.init()
        setupSearchObserver()
        Task {
            await refreshOpinions()
        }
    }
    
    func selectCategory(_ categoryId: String?) {
        guard selectedCategory != categoryId else { return }
        selectedCategory = categoryId
        Task {
            await refreshOpinions()
        }
    }
    
    private func setupSearchObserver() {
        // Search text observer
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshOpinions()
                }
            }
            .store(in: &cancellables)
            
        // Tab change observer
        $selectedTab
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshOpinions()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func refreshOpinions() async {
        currentPage = 0
        canLoadMore = true
        isLoading = true
        errorMessage = nil
        
        do {
            let currentUserId = SupabaseManager.shared.client.auth.currentSession?.user.id
            opinions = try await service.fetchOpinions(
                page: currentPage, 
                pageSize: pageSize, 
                query: searchText, 
                categoryId: selectedCategory,
                tab: selectedTab,
                currentUserId: currentUserId
            )
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
        guard canLoadMore && !isFetchingMore && !isLoading else { return }
        
        // Load more when user is near the end (e.g., 3 items from bottom)
        if let index = opinions.firstIndex(where: { $0.id == currentOpinion.id }),
           index >= opinions.count - 3 {
            await loadMoreOpinions()
        }
    }
    
    @MainActor
    private func loadMoreOpinions() async {
        isFetchingMore = true
        currentPage += 1
        
        do {
            let currentUserId = SupabaseManager.shared.client.auth.currentSession?.user.id
            let nextBatch = try await service.fetchOpinions(
                page: currentPage, 
                pageSize: pageSize, 
                query: searchText, 
                categoryId: selectedCategory,
                tab: selectedTab,
                currentUserId: currentUserId
            )
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
        // Now using server-side filtering, so we just return the fetched opinions
        return opinions
    }
}
