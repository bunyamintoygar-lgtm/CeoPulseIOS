import Foundation
import Combine

class SurveyViewModel: ObservableObject {
    @Published var surveys: [Survey] = []
    @Published var isLoading = false
    @Published var isFetchingMore = false
    @Published var errorMessage: String?
    
    @Published var surveyStats: [UUID: SurveyService.SurveyStats] = [:]
    
    @Published var searchQuery = ""
    private var searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let service = SurveyService.shared
    private var currentPage = 0
    private let pageSize = 15
    private var canLoadMore = true
    
    init() {
        setupSearchDebounce()
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
        searchSubject.send(query)
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
                let fetchedSurveys: [Survey]
                if searchQuery.isEmpty {
                    fetchedSurveys = try await service.fetchSurveys(page: currentPage, pageSize: pageSize)
                } else {
                    fetchedSurveys = try await service.searchSurveys(query: searchQuery, page: currentPage, pageSize: pageSize)
                }
                
                await MainActor.run {
                    if isRefresh {
                        self.surveys = fetchedSurveys
                    } else {
                        self.surveys.append(contentsOf: fetchedSurveys)
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
