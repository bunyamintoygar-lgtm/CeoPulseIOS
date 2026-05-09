import SwiftUI
import Combine

struct JoinSurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: JoinSurveyViewModel
    
    init(survey: Survey) {
        _viewModel = StateObject(wrappedValue: JoinSurveyViewModel(survey: survey))
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Top Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 4)
                            
                            if !viewModel.questions.isEmpty {
                                Rectangle()
                                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * CGFloat(Double(viewModel.currentQuestionIndex + 1) / Double(viewModel.questions.count)), height: 4)
                                    .animation(.spring(), value: viewModel.currentQuestionIndex)
                            }
                        }
                    }
                    .frame(height: 4)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(.purple)
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("Tekrar Dene") {
                                viewModel.fetchQuestions()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        .padding(40)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Survey Info Card
                                surveyInfoCard
                                
                                // Anonymous Warning
                                anonymousWarning
                                
                                // Questions
                                VStack(spacing: 20) {
                                    ForEach(0..<viewModel.questions.count, id: \.self) { index in
                                        QuestionActionCard(
                                            question: viewModel.questions[index],
                                            options: viewModel.options[viewModel.questions[index].id] ?? [],
                                            selectedOptions: binding(for: viewModel.questions[index].id),
                                            number: index + 1
                                        )
                                        .id(index) // Unique ID for scrolling
                                    }
                                }
                            }
                            .padding(20)
                            .padding(.bottom, 100)
                        }
                    }
                    
                    // Bottom Actions
                    bottomActions(proxy: proxy)
                }
            }
        }
        .onAppear {
            viewModel.fetchQuestions()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Ankete Katıl")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .symbolEffect(.pulse, options: .repeating)
                    Text("Canlı Oturum")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var surveyInfoCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                if let categoryId = viewModel.survey.categoryId,
                   let category = ConfigManager.shared.surveyCategories.first(where: { $0.id == categoryId }) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon ?? "tag")
                        Text(category.name)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.purple.opacity(0.15)))
                    .foregroundColor(.purple)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Canlı")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.survey.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                
                Text(viewModel.survey.description ?? "Küresel CEO Pulse Anketi")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                Label(viewModel.survey.isAnonymous ? "Anonim Katılım" : "İsimli Katılım", systemImage: viewModel.survey.isAnonymous ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(viewModel.survey.isAnonymous ? .green : .blue)
                Spacer()
                if let endDate = viewModel.survey.endDate {
                    Text("\(endDate.daysFromNow()) gün kaldı")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
        )
    }
    
    private var anonymousWarning: some View {
        HStack(spacing: 16) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 20))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.green)
                .symbolEffect(.pulse, options: .repeating)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Gizlilik Koruması")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("Yanıtlarınız şifrelenir ve güvenle saklanır.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.green.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.1), lineWidth: 1))
    }
    
    private func bottomActions(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .white.opacity(0.05), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
            
            HStack(spacing: 12) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Daha Sonra")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                }
                
                Button(action: {
                    if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            viewModel.currentQuestionIndex += 1
                            proxy.scrollTo(viewModel.currentQuestionIndex, anchor: .top)
                        }
                    } else {
                        Task {
                            let success = await viewModel.submitAnswers()
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Anketi Bitir" : "Sıradaki Soru")
                            Image(systemName: viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "checkmark.circle.fill" : "arrow.right")
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [Color(hex: "6C38FF"), .purple], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
                    )
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                Text("Yanıtlarınız güvenli protokoller ile korunmaktadır.")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(AppColors.textSecondary)
            .padding(.bottom, 10)
        }
        .padding(.top, 8)
        .background(
            AppColors.background
                .overlay(
                    LinearGradient(colors: [Color.black.opacity(0.2), .clear], startPoint: .bottom, endPoint: .top)
                )
        )
    }
    
    private func binding(for questionId: UUID) -> Binding<Set<UUID>> {
        Binding(
            get: { viewModel.answers[questionId] ?? [] },
            set: { viewModel.answers[questionId] = $0 }
        )
    }
}

struct QuestionActionCard: View {
    let question: SurveyQuestion
    let options: [SurveyOption]
    @Binding var selectedOptions: Set<UUID>
    let number: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("SORU \(number)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.purple)
                    
                    Text(question.questionText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                }
                Spacer()
                if question.isRequired {
                    Image(systemName: "asterisk")
                        .font(.system(size: 10))
                        .foregroundColor(.red.opacity(0.8))
                }
            }
            
            if question.questionType == .multipleChoice {
                HStack(spacing: 4) {
                    Image(systemName: "checklist")
                    Text("Birden fazla seçim yapabilirsiniz (Maks: \(question.maxSelections))")
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.05)))
            }
            
            VStack(spacing: 12) {
                ForEach(options) { option in
                    let isSelected = selectedOptions.contains(option.id)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if question.questionType == .singleChoice {
                                selectedOptions = [option.id]
                            } else {
                                if isSelected {
                                    selectedOptions.remove(option.id)
                                } else if selectedOptions.count < question.maxSelections {
                                    selectedOptions.insert(option.id)
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                if question.questionType == .singleChoice {
                                    Circle()
                                        .stroke(isSelected ? Color.purple : Color.white.opacity(0.2), lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                    if isSelected {
                                        Circle()
                                            .fill(Color.purple)
                                            .frame(width: 12, height: 12)
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? Color.purple : Color.white.opacity(0.2), lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.purple)
                                    }
                                }
                            }
                            
                            Text(option.text)
                                .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Color.purple.opacity(0.1) : Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                        .scaleEffect(isSelected ? 1.02 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.05), lineWidth: 1))
        )
    }
}

// Dummy Data for Participation
let q1Id = UUID()
let q2Id = UUID()
let dummyQuestions = [
    SurveyQuestion(id: q1Id, surveyId: UUID(), questionText: "2026 yılında yapay zeka yatırımlarınızın toplam bütçenizdeki payı ne olacak?", questionType: .singleChoice, isRequired: true, maxSelections: 1, order: 1),
    SurveyQuestion(id: q2Id, surveyId: UUID(), questionText: "Yapay zeka yatırımlarınızın öncelikli amacı nedir?", questionType: .multipleChoice, isRequired: true, maxSelections: 2, order: 2)
]

let dummyOptions: [UUID: [SurveyOption]] = [
    q1Id: [
        SurveyOption(id: UUID(), questionId: q1Id, optionText: "%0 (Yatırım yapmayacağız)", order: 1),
        SurveyOption(id: UUID(), questionId: q1Id, optionText: "%1 - %5", order: 2),
        SurveyOption(id: UUID(), questionId: q1Id, optionText: "%6 - %10", order: 3),
        SurveyOption(id: UUID(), questionId: q1Id, optionText: "%11 - %20", order: 4),
        SurveyOption(id: UUID(), questionId: q1Id, optionText: "%21 ve üzeri", order: 5)
    ],
    q2Id: [
        SurveyOption(id: UUID(), questionId: q2Id, optionText: "Operasyonel verimliliği artırmak", order: 1),
        SurveyOption(id: UUID(), questionId: q2Id, optionText: "Maliyetleri düşürmek", order: 2),
        SurveyOption(id: UUID(), questionId: q2Id, optionText: "Yeni ürün/hizmet geliştirmek", order: 3),
        SurveyOption(id: UUID(), questionId: q2Id, optionText: "Müşteri deneyimini iyileştirmek", order: 4),
        SurveyOption(id: UUID(), questionId: q2Id, optionText: "Gelirleri artırmak", order: 5)
    ]
]

extension SurveyOption {
    var text: String { optionText }
}
