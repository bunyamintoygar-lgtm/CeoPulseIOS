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
    
    // Upcoming filter: All roundtables from today (00:00) onwards
    var upcomingRoundtables: [Roundtable] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return roundtables.filter { $0.startTime >= today }
            .sorted(by: { $0.startTime < $1.startTime })
    }
    
    private let service = RoundtableService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
        
        // Ensure configs are loaded
        Task {
            if ConfigManager.shared.roundtableCategories.isEmpty {
                await ConfigManager.shared.fetchConfigs()
            }
        }
    }
    
    private func setupSubscribers() {
        // Refresh when category or tab changes
        Publishers.CombineLatest($selectedCategory, $selectedTab)
            .sink { [weak self] _ in
                Task { await self?.loadRoundtables() }
            }
            .store(in: &cancellables)
            
        // Separate search handling
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { await self?.loadRoundtables() }
            }
            .store(in: &cancellables)
            
        // Observe ConfigManager for category updates
        ConfigManager.shared.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
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
            case 0: status = nil
            case 1:
                do {
                    let session = try await SupabaseManager.shared.client.auth.session
                    moderatorId = session.user.id
                } catch {
                    print("Session error: \(error)")
                }
            case 2: status = .active
            case 3: status = .completed
            default: status = nil
            }
            
            var fetched = try await service.fetchRoundtables(
                status: status,
                category: selectedCategory,
                searchText: searchText,
                moderatorId: moderatorId
            )
            
            if !searchText.isEmpty {
                let lowerSearch = searchText.lowercased(with: Locale(identifier: "tr_TR"))
                fetched = fetched.filter { roundtable in
                    roundtable.title.lowercased(with: Locale(identifier: "tr_TR")).contains(lowerSearch) ||
                    (roundtable.description?.lowercased(with: Locale(identifier: "tr_TR")).contains(lowerSearch) ?? false)
                }
            }
            
            self.roundtables = fetched
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
