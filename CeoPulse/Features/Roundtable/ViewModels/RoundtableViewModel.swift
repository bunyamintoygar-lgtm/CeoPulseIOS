import SwiftUI
import Combine
import Auth
import Supabase

class RoundtableViewModel: ObservableObject {
    @Published var roundtables: [Roundtable] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedCategory = "Tümü"
    @Published var selectedTab = 0
    @Published var searchText = ""
    @Published var isSearching = false
    
    private let service = RoundtableService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        // Refresh when category, tab or search text changes
        Publishers.CombineLatest3($selectedCategory, $selectedTab, $searchText)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
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
            var status: RoundtableStatus? = nil
            var moderatorId: UUID? = nil
            
            // tabs = ["Tüm Masalar", "Kendi Açtıklarım", "Devam Edenler", "Geçmiş Masalar"]
            switch selectedTab {
            case 0: // Tüm Masalar
                status = nil
            case 1: // Kendi Açtıklarım
                let session = try? await SupabaseManager.shared.client.auth.session
                moderatorId = session?.user.id
            case 2: // Devam Edenler
                status = .active
            case 3: // Geçmiş Masalar
                status = .completed
            default:
                status = nil
            }
            
            self.roundtables = try await service.fetchRoundtables(
                status: status,
                category: selectedCategory,
                searchText: searchText,
                moderatorId: moderatorId
            )
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
