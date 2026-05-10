import Foundation
import Combine

class SurveyViewModel: ObservableObject {
    @Published var surveys: [Survey] = []
    @Published var isLoading = false
    @Published var isFetchingMore = false
    @Published var errorMessage: String?
    
    @Published var surveyStats: [UUID: SurveyService.SurveyStats] = [:]
    
    @Published var searchQuery = ""
    @Published var selectedCategoryId: String? = nil
    @Published var selectedTab = "Keşfet"
    @Published var currentUserId: UUID? = nil
    @Published var participatedSurveyIds: Set<UUID> = []
    private var searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let service = SurveyService.shared
    private var currentPage = 0
    private let pageSize = 15
    private var canLoadMore = true
    
    init() {
        setupSearchDebounce()
        fetchInitialData()
    }
    
    private func fetchInitialData() {
        Task {
            do {
                let userId = try await service.fetchCurrentUserId()
                let participatedIds = try await service.fetchParticipatedSurveyIds()
                await MainActor.run {
                    self.currentUserId = userId
                    self.participatedSurveyIds = Set(participatedIds)
                    self.fetchSurveys(isRefresh: true)
                }
            } catch {
                print("Failed to fetch initial survey data: \(error)")
                self.fetchSurveys(isRefresh: true)
            }
        }
    }
    
    private func setupSearchDebounce() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.fetchSurveys(isRefresh: true)
            }
            .store(in: &cancellables)
    }
    
    func updateSearchQuery(_ query: String) {
        searchQuery = query
        if query.isEmpty {
            fetchSurveys(isRefresh: true)
        } else {
            searchSubject.send(query)
        }
    }
    
    func updateCategoryFilter(_ categoryId: String?) {
        selectedCategoryId = categoryId
        fetchSurveys(isRefresh: true)
    }
    
    func updateSelectedTab(_ tab: String) {
        selectedTab = tab
        fetchSurveys(isRefresh: true)
    }
    
    func fetchSurveys(isRefresh: Bool = true) {
        if isRefresh {
            currentPage = 0
            canLoadMore = true
            isLoading = true
        } else {
            guard canLoadMore && !isFetchingMore else { return }
            isFetchingMore = true
        }
        
        errorMessage = nil
        Task {
            do {
                let statusFilter: Survey.SurveyStatus?
                var statusesFilter: [Survey.SurveyStatus]? = nil
                
                switch selectedTab {
                case "Keşfet":
                    statusFilter = nil
                    statusesFilter = [.active] // Fetch active ones to filter later
                case "Aktif Anketler": 
                    statusFilter = .active
                    statusesFilter = nil
                case "Tamamlananlar": 
                    statusFilter = nil // We'll filter by participatedSurveyIds
                case "Oluşturduklarım": 
                    statusFilter = nil 
                case "Arşiv": 
                    statusFilter = .archived
                default: 
                    statusFilter = .active
                }
                
                let participatedIds = try await service.fetchParticipatedSurveyIds()
                let fetchedSurveys = try await service.fetchSurveys(
                    query: searchQuery.isEmpty ? nil : searchQuery,
                    categoryId: selectedCategoryId,
                    creatorId: selectedTab == "Oluşturduklarım" ? currentUserId : nil,
                    status: statusFilter,
                    statuses: statusesFilter,
                    ids: selectedTab == "Tamamlananlar" ? participatedIds : nil,
                    page: currentPage,
                    pageSize: pageSize
                )
                
                await MainActor.run {
                    self.participatedSurveyIds = Set(participatedIds)
                    
                    var processedSurveys = fetchedSurveys
                    
                    if selectedTab == "Aktif Anketler" {
                        // Only show active and NOT voted
                        processedSurveys = processedSurveys.filter { !self.participatedSurveyIds.contains($0.id) }
                    } else if selectedTab == "Arşiv" {
                        // Include expired surveys as well
                        let now = Date()
                        processedSurveys = processedSurveys.filter { $0.status == .archived || ($0.endDate != nil && $0.endDate! < now) }
                    }
                    
                    if isRefresh {
                        self.surveys = processedSurveys
                    } else {
                        self.surveys.append(contentsOf: processedSurveys)
                    }
                    
                    self.canLoadMore = fetchedSurveys.count == pageSize
                    self.currentPage += 1
                    self.isLoading = false
                    self.isFetchingMore = false
                    
                    // Fetch stats for these surveys
                    Task {
                        await self.fetchStats(for: fetchedSurveys)
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Anketler yüklenirken bir hata oluştu: \(error.localizedDescription)"
                    self.isLoading = false
                    self.isFetchingMore = false
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentSurvey: Survey) {
        guard let lastSurvey = surveys.last, lastSurvey.id == currentSurvey.id else { return }
        fetchSurveys(isRefresh: false)
    }
    
    func deleteSurvey(_ survey: Survey) {
        Task {
            do {
                try await service.deleteSurvey(surveyId: survey.id)
                await MainActor.run {
                    self.surveys.removeAll { $0.id == survey.id }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Anket silinemedi: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func generateShareLink(for survey: Survey) -> URL {
        // Bu link ileride Universal Link (ceopulse.app) olarak yapılandırılacak
        let urlString = "https://ceopulse.app/survey/\(survey.id.uuidString)"
        return URL(string: urlString)!
    }
    
    var activeSurveys: [Survey] {
        surveys.filter { $0.status == .active }
    }
    
    var completedSurveys: [Survey] {
        surveys.filter { $0.status == .completed }
    }
    
    var mySurveys: [Survey] {
        // When in "Oluşturduklarım" tab, we already filtered by creatorId in the fetchSurveys call
        // but let's be double sure and handle it if we ever use this list elsewhere.
        surveys
    }
    
    private func fetchStats(for surveys: [Survey]) async {
        for survey in surveys {
            do {
                let stats = try await service.fetchSurveyStats(surveyId: survey.id)
                await MainActor.run {
                    self.surveyStats[survey.id] = stats
                }
            } catch {
                print("Failed to fetch stats for \(survey.id): \(error)")
            }
        }
    }
}
