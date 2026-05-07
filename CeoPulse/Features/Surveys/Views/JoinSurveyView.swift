import SwiftUI

struct JoinSurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    let survey: Survey
    
    @State private var currentQuestionIndex = 0
    @State private var answers: [UUID: Set<UUID>] = [:]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Survey Info Card
                        surveyInfoCard
                        
                        // Anonymous Warning
                        anonymousWarning
                        
                        // Questions
                        VStack(spacing: 20) {
                            ForEach(0..<dummyQuestions.count, id: \.self) { index in
                                QuestionActionCard(
                                    question: dummyQuestions[index],
                                    options: dummyOptions[dummyQuestions[index].id] ?? [],
                                    selectedOptions: binding(for: dummyQuestions[index].id),
                                    number: index + 1
                                )
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
                
                // Bottom Actions
                bottomActions
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "pencil.and.outline")
                        .foregroundColor(.purple)
                    Text("Ankete Katıl")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Görüşünüz bizim için çok değerli.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var surveyInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 4) {
                    Text("AKTİF")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                    
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                    Text("Anonim")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("5 gün kaldı")
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            }
            
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(survey.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(survey.description ?? "Küresel CEO Pulse Anketi")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Participation Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 4)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: 0.62)
                        .stroke(LinearGradient(colors: [.purple, Color(hex: "6C38FF")], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("%62")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Katılım")
                            .font(.system(size: 8))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            HStack(spacing: -8) {
                ForEach(1...4, id: \.self) { i in
                    Image("ceo_profile_\(i)")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                }
                Text("+248")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.purple.opacity(0.3))
                    .clipShape(Circle())
                    .padding(.leading, 4)
                
                Text("Toplam 248 CEO oy verdi")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.leading, 8)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
    }
    
    private var anonymousWarning: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.purple.opacity(0.1)).frame(width: 32, height: 32)
                Image(systemName: "info.circle.fill").foregroundColor(.purple)
            }
            Text("Anket anonimdir. Yanıtlarınız sadece toplu istatistiklerde değerlendirilir.")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple.opacity(0.1), lineWidth: 1))
    }
    
    private var bottomActions: some View {
        VStack(spacing: 12) {
            Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1)
            
            HStack(spacing: 16) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    HStack {
                        Image(systemName: "bookmark")
                        Text("Kaydet ve Çık")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Button(action: {}) {
                    HStack {
                        Text("Devam Et")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "6C38FF"))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            
            HStack {
                Text("1 / 4").font(.system(size: 12, weight: .bold))
                HStack(spacing: 6) {
                    Circle().fill(Color.purple).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 6, height: 6)
                }
                .padding(.leading, 10)
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            
            HStack(spacing: 8) {
                Image(systemName: "lock.fill").font(.system(size: 10))
                Text("Yanıtlarınız güvenle korunur ve anonim olarak işlenir.").font(.system(size: 10))
            }
            .foregroundColor(AppColors.textSecondary)
            .padding(.bottom, 20)
        }
        .background(AppColors.background)
    }
    
    private func binding(for questionId: UUID) -> Binding<Set<UUID>> {
        Binding(
            get: { self.answers[questionId] ?? [] },
            set: { self.answers[questionId] = $0 }
        )
    }
}

struct QuestionActionCard: View {
    let question: SurveyQuestion
    let options: [SurveyOption]
    @Binding var selectedOptions: Set<UUID>
    let number: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(number). Soru").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text("(Zorunlu)").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
            }
            
            Text(question.questionText)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            if question.questionType == .multipleChoice {
                Text("En fazla \(question.maxSelections) seçenek işaretleyebilirsiniz.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(spacing: 10) {
                ForEach(options) { option in
                    Button(action: {
                        if question.questionType == .singleChoice {
                            selectedOptions = [option.id]
                        } else {
                            if selectedOptions.contains(option.id) {
                                selectedOptions.remove(option.id)
                            } else if selectedOptions.count < question.maxSelections {
                                selectedOptions.insert(option.id)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedOptions.contains(option.id) ? 
                                  (question.questionType == .singleChoice ? "largecircle.fill.circle" : "checkmark.square.fill") :
                                  (question.questionType == .singleChoice ? "circle" : "square"))
                                .foregroundColor(selectedOptions.contains(option.id) ? .purple : AppColors.textSecondary)
                            
                            Text(option.text)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(selectedOptions.contains(option.id) ? Color.purple.opacity(0.1) : Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedOptions.contains(option.id) ? Color.purple : Color.clear, lineWidth: 1))
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
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
