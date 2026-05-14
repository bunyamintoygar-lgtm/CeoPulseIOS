import Foundation
import SwiftUI
import Combine

class RoundtableViewModel: ObservableObject {
    @Published var roundtables: [Roundtable] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedCategory = "Tümü"
    @Published var selectedTab = 0
    
    private let service = RoundtableService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        // Refresh when category or tab changes
        Publishers.CombineLatest($selectedCategory, $selectedTab)
            .sink { [weak self] _ in
                Task { await self?.loadRoundtables() }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadRoundtables() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let status: RoundtableStatus? = {
                switch selectedTab {
                case 0: return .active
                case 1: return .upcoming // Or handle "Following" specifically if needed
                case 2: return .completed
                default: return nil
                }
            }()
            
            self.roundtables = try await service.fetchRoundtables(status: status, category: selectedCategory)
            isLoading = false
        } catch {
            print("Error loading roundtables: \(error)")
            self.errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    @MainActor
    func refresh() async {
        await loadRoundtables()
    }
}
