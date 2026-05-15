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
    
    // Upcoming filter (Today and future)
    var upcomingRoundtables: [Roundtable] {
        roundtables.filter { $0.startTime >= Date().addingTimeInterval(-3600) }
            .sorted(by: { $0.startTime < $1.startTime })
    }
    
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
            
        // Separate search handling to handle Turkish casing better on client side if needed
        $searchText
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
                do {
                    let session = try await SupabaseManager.shared.client.auth.session
                    moderatorId = session.user.id
                } catch {
                    print("Session error: \(error)")
                }
            case 2: // Devam Edenler
                status = .active
            case 3: // Geçmiş Masalar
                status = .completed
            default:
                status = nil
            }
            
            // Use Turkish-aware casing for search if possible, or handle on client side
            // For now, we use server-side ilike which is generally case-insensitive
            self.roundtables = try await service.fetchRoundtables(
                status: status,
                category: selectedCategory,
                searchText: searchText,
                moderatorId: moderatorId
            )
            
            // Optional: Client side filtering for better Turkish character support
            if !searchText.isEmpty {
                let lowerSearch = searchText.lowercased(with: Locale(identifier: "tr_TR"))
                self.roundtables = self.roundtables.filter { roundtable in
                    roundtable.title.lowercased(with: Locale(identifier: "tr_TR")).contains(lowerSearch) ||
                    (roundtable.description?.lowercased(with: Locale(identifier: "tr_TR")).contains(lowerSearch) ?? false)
                }
            }
            
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
