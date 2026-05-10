import SwiftUI
import Combine

struct SurveyResultsView: View {
    @StateObject private var viewModel: SurveyResultsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(survey: Survey) {
        _viewModel = StateObject(wrappedValue: SurveyResultsViewModel(survey: survey))
    }
    
    @State private var exportURL: URL?
    @State private var isShowingShareSheet = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.purple)
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button(LocalizedStringKey("rt_join_title")) {
                            viewModel.fetchData()
                        }
                        .padding()
                        .background(Capsule().fill(Color.purple))
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            participationStats
                            
                            ForEach(viewModel.questions) { question in
                                QuestionResultCard(
                                    question: question,
                                    options: viewModel.options[question.id] ?? [],
                                    results: viewModel.results
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(LocalizedStringKey("survey_results_title"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: exportToPDF) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
    }
    
    private func exportToPDF() {
        // Create a simple report view for PDF
        let reportView = VStack(spacing: 20) {
            Text(viewModel.survey.title)
                .font(.title)
                .bold()
            
            Text(NSLocalizedString("survey_report_title", comment: ""))
                .font(.headline)
            
            Text("\(NSLocalizedString("survey_total_participation", comment: "")): \(viewModel.participationCount)")
            
            ForEach(viewModel.questions) { question in
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.questionText).bold()
                    ForEach(viewModel.options[question.id] ?? []) { option in
                        let votes = viewModel.results[option.id] ?? 0
                        HStack {
                            Text(option.optionText)
                            Spacer()
                            Text("\(votes) \(NSLocalizedString("survey_votes_label", comment: ""))")
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
        }
        .padding()
        .frame(width: 595) // A4 width in points
        .background(Color.white)
        .foregroundColor(.black)
        
        if let url = PDFManager.shared.generatePDF(view: reportView, filename: "CEO_Pulse_Rapor_\(viewModel.survey.id.uuidString.prefix(6))") {
            self.exportURL = url
            self.isShowingShareSheet = true
        }
    }
    
    private var participationStats: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("survey_total_participation"))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                Text("\(viewModel.participationCount)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(LocalizedStringKey("rt_field_status"))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                Text(viewModel.survey.endDate != nil && viewModel.survey.endDate! < Date() ? NSLocalizedString("survey_completed_status", comment: "") : NSLocalizedString("rt_status_active", comment: ""))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.survey.endDate != nil && viewModel.survey.endDate! < Date() ? .green : .orange)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
    }
}

class SurveyResultsViewModel: ObservableObject {
    let survey: Survey
    @Published var questions: [SurveyQuestion] = []
    @Published var options: [UUID: [SurveyOption]] = [:]
    @Published var results: [UUID: Int] = [:]
    @Published var participationCount = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = SurveyService.shared
    
    init(survey: Survey) {
        self.survey = survey
    }
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let fetchedQuestions = service.fetchQuestions(for: survey.id)
                async let fetchedResults = service.fetchResults(for: survey.id)
                async let count = service.fetchParticipationCount(for: survey.id)
                
                let (qs, rs, c) = try await (fetchedQuestions, fetchedResults, count)
                
                var opts: [UUID: [SurveyOption]] = [:]
                for q in qs {
                    opts[q.id] = try await service.fetchOptions(for: q.id)
                }
                
                DispatchQueue.main.async {
                    self.questions = qs
                    self.results = rs
                    self.participationCount = c
                    self.options = opts
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "\(NSLocalizedString("survey_results_error", comment: "")): \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

struct QuestionResultCard: View {
    let question: SurveyQuestion
    let options: [SurveyOption]
    let results: [UUID: Int]
    
    private var totalVotes: Int {
        options.reduce(0) { $0 + (results[$1.id] ?? 0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.questionText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(options) { option in
                    OptionResultRow(
                        text: option.optionText,
                        votes: results[option.id] ?? 0,
                        totalVotes: totalVotes
                    )
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct OptionResultRow: View {
    let text: String
    let votes: Int
    let totalVotes: Int
    
    private var percentage: Double {
        totalVotes > 0 ? Double(votes) / Double(totalVotes) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.purple)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.05))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * percentage)
                }
            }
            .frame(height: 8)
            
            Text("\(votes) \(NSLocalizedString("survey_votes_label", comment: ""))")
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}
