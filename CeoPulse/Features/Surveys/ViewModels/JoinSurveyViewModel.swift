import Foundation
import SwiftUI
import Combine

class JoinSurveyViewModel: ObservableObject {
    let survey: Survey
    @Published var questions: [SurveyQuestion] = []
    @Published var options: [UUID: [SurveyOption]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentQuestionIndex = 0 {
        didSet { saveDraft() }
    }
    @Published var answers: [UUID: Set<UUID>] = [:] {
        didSet { saveDraft() }
    }
    @Published var showingResumeAlert = false
    
    private let service = SurveyService.shared
    private let draftManager = SurveyResponseDraftManager.shared
    
    init(survey: Survey) {
        self.survey = survey
    }
    
    func checkDraft() {
        if draftManager.hasDraft(for: survey.id) && answers.isEmpty {
            // Sorma, sessizce kaldığı yerden devam et
            loadDraft()
        }
    }
    
    func loadDraft() {
        if let draft = draftManager.loadDraft(for: survey.id) {
            self.answers = draft.answers
            self.currentQuestionIndex = draft.lastQuestionIndex
        }
    }
    
    func clearDraft() {
        draftManager.clearDraft(for: survey.id)
    }
    
    private func saveDraft() {
        if !answers.isEmpty {
            draftManager.saveDraft(surveyId: survey.id, answers: answers, lastIndex: currentQuestionIndex)
        }
    }
    
    func fetchQuestions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedQuestions = try await service.fetchQuestions(for: survey.id)
                var fetchedOptions: [UUID: [SurveyOption]] = [:]
                
                for question in fetchedQuestions {
                    let qOptions = try await service.fetchOptions(for: question.id)
                    fetchedOptions[question.id] = qOptions
                }
                
                DispatchQueue.main.async {
                    self.questions = fetchedQuestions
                    self.options = fetchedOptions
                    self.isLoading = false
                    self.checkDraft()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Sorular yüklenirken hata oluştu: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func submitAnswers() async -> Bool {
        await MainActor.run { 
            self.isLoading = true 
            self.errorMessage = nil
        }
        
        do {
            try await service.submitVote(surveyId: survey.id, answers: answers)
            clearDraft()
            await MainActor.run { self.isLoading = false }
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Yanıtlarınız gönderilirken hata oluştu: \(error.localizedDescription)"
                self.isLoading = false
            }
            return false
        }
    }
}
