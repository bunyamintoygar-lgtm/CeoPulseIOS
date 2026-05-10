import Foundation
import Combine

class SurveyViewModel: ObservableObject {
    // MARK: - Published States
    @Published var activeSurveysList: [Survey] = []
    @Published var completedSurveysList: [Survey] = []
    @Published var mySurveysList: [Survey] = []
    @Published var archivedSurveysList: [Survey] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var surveyStats: [UUID: SurveyService.SurveyStats] = [:]
    
    @Published var searchQuery = ""
    @Published var selectedCategoryId: String? = nil
    @Published var selectedTab = "discovery" // Internal keys: discovery, active, completed, my_surveys, archive
    
    @Published var currentUserId: UUID? = nil
    @Published var totalUserCount: Int = 1
    @Published var participatedSurveyIds: Set<UUID> = []
    
    // MARK: - Pagination States
    private var pages: [String: Int] = ["active": 0, "completed": 0, "my_surveys": 0, "archive": 0]
    private var canLoadMores: [String: Bool] = ["active": true, "completed": true, "my_surveys": true, "archive": true]
    @Published var isFetchingMore = false
    
    // MARK: - Private Properties
    private var searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let service = SurveyService.shared
    private let pageSize = 15
    
    init() {
        setupSearchDebounce()
        fetchInitialData()
    }
    
    // MARK: - Setup
    private func setupSearchDebounce() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.refreshAll()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func updateSearchQuery(_ query: String) {
        searchQuery = query
        if query.isEmpty {
            refreshAll()
        } else {
            searchSubject.send(query)
        }
    }
    
    func updateCategoryFilter(_ categoryId: String?) {
        selectedCategoryId = categoryId
        refreshAll()
    }
    
    func updateSelectedTab(_ tab: String) {
        // Tab switching is now instant. No data fetching required here.
        selectedTab = tab
    }
    
    func refreshAll() {
        fetchInitialData(isRefresh: true)
    }
    
    // MARK: - Data Fetching
    private func fetchInitialData(isRefresh: Bool = false) {
        Task {
            await MainActor.run {
                if isRefresh {
                    pages = ["active": 0, "completed": 0, "my_surveys": 0, "archive": 0]
                    canLoadMores = ["active": true, "completed": true, "my_surveys": true, "archive": true]
                    activeSurveysList = []
                    completedSurveysList = []
                    mySurveysList = []
                    archivedSurveysList = []
                }
                isLoading = true
                errorMessage = nil
            }
            
            // Fetch Base Data Concurrently
            do {
                async let userIdReq = service.fetchCurrentUserId()
                async let pIdsReq = service.fetchParticipatedSurveyIds()
                async let countReq = service.fetchTotalUserCount()
                
                let (uId, pIds, count) = try await (userIdReq, pIdsReq, countReq)
                
                await MainActor.run {
                    self.currentUserId = uId
                    self.participatedSurveyIds = Set(pIds)
                    self.totalUserCount = count
                }
            } catch {
                print("Failed to fetch base data: \(error)")
            }
            
            // Now fetch the 4 categories concurrently
            await fetchAllCategoriesConcurrent(isRefresh: isRefresh)
        }
    }
    
    private func fetchAllCategoriesConcurrent(isRefresh: Bool) async {
        let uId = await MainActor.run { self.currentUserId }
        let pIds = await MainActor.run { self.participatedSurveyIds }
        let query = await MainActor.run { self.searchQuery.isEmpty ? nil : self.searchQuery }
        let catId = await MainActor.run { self.selectedCategoryId }
        
        // Active
        async let activeReq = service.fetchSurveys(query: query, categoryId: catId, status: .active, statuses: nil, ids: nil, page: 0, pageSize: pageSize)
        
        // Archive
        async let archiveReq = service.fetchSurveys(query: query, categoryId: catId, status: .archived, statuses: nil, ids: nil, page: 0, pageSize: pageSize)
        
        // My Surveys
        async let myReq = uId != nil ? service.fetchSurveys(query: query, categoryId: catId, creatorId: uId, status: nil, statuses: nil, ids: nil, page: 0, pageSize: pageSize) : []
        
        // Completed
        let pIdArray = Array(pIds)
        let completedReq: [Survey]
        if pIdArray.isEmpty {
            completedReq = []
        } else {
            completedReq = (try? await service.fetchSurveys(query: query, categoryId: catId, status: nil, statuses: [.active, .archived], ids: pIdArray, page: 0, pageSize: pageSize)) ?? []
        }
        
        let (activeRes, archiveRes, myRes) = await (
            (try? activeReq) ?? [],
            (try? archiveReq) ?? [],
            (try? myReq) ?? []
        )
        
        await MainActor.run {
            // Filter out participated from active
            self.activeSurveysList = activeRes.filter { !pIds.contains($0.id) }
            self.archivedSurveysList = archiveRes
            self.mySurveysList = myRes
            self.completedSurveysList = completedReq
            
            // Update pagination states
            self.canLoadMores["active"] = activeRes.count == pageSize
            self.canLoadMores["archive"] = archiveRes.count == pageSize
            self.canLoadMores["my_surveys"] = myRes.count == pageSize
            self.canLoadMores["completed"] = completedReq.count == pageSize
            
            self.pages["active"] = 1
            self.pages["archive"] = 1
            self.pages["my_surveys"] = 1
            self.pages["completed"] = 1
            
            self.isLoading = false
            
            // Fetch stats for all these surveys
            let allFetched = activeRes + archiveRes + myRes + completedReq
            Task { await self.fetchStats(for: allFetched) }
        }
    }
    
    func loadMoreIfNeeded(currentSurvey: Survey, forTab: String) {
        guard let list = listForTab(forTab), let lastSurvey = list.last, lastSurvey.id == currentSurvey.id else { return }
        
        let canLoad = canLoadMores[forTab] ?? false
        guard canLoad && !isFetchingMore else { return }
        
        isFetchingMore = true
        let pageToLoad = pages[forTab] ?? 1
        
        Task {
            let uId = await MainActor.run { self.currentUserId }
            let pIds = await MainActor.run { self.participatedSurveyIds }
            let query = await MainActor.run { self.searchQuery.isEmpty ? nil : self.searchQuery }
            let catId = await MainActor.run { self.selectedCategoryId }
            
            var fetched: [Survey] = []
            
            do {
                if forTab == "active" {
                    fetched = try await service.fetchSurveys(query: query, categoryId: catId, status: .active, statuses: nil, ids: nil, page: pageToLoad, pageSize: pageSize)
                } else if forTab == "archive" {
                    fetched = try await service.fetchSurveys(query: query, categoryId: catId, status: .archived, statuses: nil, ids: nil, page: pageToLoad, pageSize: pageSize)
                } else if forTab == "my_surveys", let uId = uId {
                    fetched = try await service.fetchSurveys(query: query, categoryId: catId, creatorId: uId, status: nil, statuses: nil, ids: nil, page: pageToLoad, pageSize: pageSize)
                } else if forTab == "completed", !pIds.isEmpty {
                    fetched = try await service.fetchSurveys(query: query, categoryId: catId, status: nil, statuses: [.active, .archived], ids: Array(pIds), page: pageToLoad, pageSize: pageSize)
                }
            } catch {
                print("Failed to load more for \(forTab): \(error)")
            }
            
            await MainActor.run {
                if forTab == "active" {
                    let filtered = fetched.filter { !pIds.contains($0.id) }
                    self.activeSurveysList.append(contentsOf: filtered)
                } else if forTab == "archive" {
                    self.archivedSurveysList.append(contentsOf: fetched)
                } else if forTab == "my_surveys" {
                    self.mySurveysList.append(contentsOf: fetched)
                } else if forTab == "completed" {
                    self.completedSurveysList.append(contentsOf: fetched)
                }
                
                self.canLoadMores[forTab] = fetched.count == pageSize
                self.pages[forTab] = pageToLoad + 1
                self.isFetchingMore = false
                
                Task { await self.fetchStats(for: fetched) }
            }
        }
    }
    
    private func listForTab(_ tab: String) -> [Survey]? {
        switch tab {
        case "active": return activeSurveysList
        case "completed": return completedSurveysList
        case "my_surveys": return mySurveysList
        case "archive": return archivedSurveysList
        default: return nil
        }
    }
    
    func deleteSurvey(_ survey: Survey) {
        Task {
            do {
                try await service.deleteSurvey(surveyId: survey.id)
                await MainActor.run {
                    self.activeSurveysList.removeAll { $0.id == survey.id }
                    self.completedSurveysList.removeAll { $0.id == survey.id }
                    self.mySurveysList.removeAll { $0.id == survey.id }
                    self.archivedSurveysList.removeAll { $0.id == survey.id }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Anket silinemedi: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func generateShareLink(for survey: Survey) -> URL {
        let urlString = "https://ceopulse.app/survey/\(survey.id.uuidString)"
        return URL(string: urlString)!
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
