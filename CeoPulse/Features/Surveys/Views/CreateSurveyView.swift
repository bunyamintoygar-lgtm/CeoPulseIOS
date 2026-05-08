import SwiftUI

struct CreateSurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 1
    
    // Step 1: Details
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: SurveyCategory?
    @State private var targetAudience = "Herkese Açık"
    @State private var hasEndDate = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @StateObject private var configManager = ConfigManager.shared
    
    // Step 2: Questions
    @State private var questions: [DraftQuestion] = [
        DraftQuestion(text: "2026 yılında yapay zeka yatırımlarınızın toplam bütçenizdeki payı ne olacak?", options: ["%0 (Yatırım yapmayacağız)", "%1 - %5", "%6 - %10", "%11 - %20", "%21 ve üzeri"], type: .singleChoice)
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                headerView
                
                // Stepper
                surveyStepper
                
                ScrollView {
                    VStack(spacing: 24) {
                        if currentStep == 1 {
                            step1Details
                        } else if currentStep == 2 {
                            step2Questions
                        } else if currentStep == 3 {
                            step3Settings
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
                    Image(systemName: "plus.square.fill.on.square.fill")
                        .foregroundColor(.purple)
                    Text("Yeni Anket Ekle")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Anketinizi oluşturun ve topluluğunuzla paylaşın.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "archivebox")
                    Text("Taslaklar")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var surveyStepper: some View {
        HStack {
            StepperItem(number: 1, title: "Detaylar", isCurrent: currentStep == 1, isCompleted: currentStep > 1)
            line
            StepperItem(number: 2, title: "Sorular", isCurrent: currentStep == 2, isCompleted: currentStep > 2)
            line
            StepperItem(number: 3, title: "Ayarlar", isCurrent: currentStep == 3, isCompleted: currentStep > 3)
            line
            StepperItem(number: 4, title: "Önizleme", isCurrent: currentStep == 4, isCompleted: currentStep > 4)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
    }
    
    private var line: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .offset(y: -10)
    }
    
    private var step1Details: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title & Description
            VStack(alignment: .leading, spacing: 16) {
                Text("Anket Detayları")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anket Başlığı *").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    ZStack(alignment: .bottomTrailing) {
                        TextEditor(text: $title)
                            .frame(height: 80)
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        Text("\(title.count)/120")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anket Açıklaması").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    ZStack(alignment: .bottomTrailing) {
                        TextEditor(text: $description)
                            .frame(height: 120)
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        Text("\(description.count)/500")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(8)
                    }
                }
            }
            
            // Category
            VStack(alignment: .leading, spacing: 8) {
                Text("Kategori").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                
                Menu {
                    ForEach(configManager.surveyCategories) { category in
                        Button(action: { selectedCategory = category }) {
                            HStack {
                                Text(category.name)
                                if let icon = category.icon {
                                    Image(systemName: icon)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: selectedCategory?.icon ?? "square.grid.2x2")
                        Text(selectedCategory?.name ?? "Kategori seçin")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .foregroundColor(selectedCategory == nil ? AppColors.textSecondary : .white)
                }
                .onAppear {
                    if configManager.surveyCategories.isEmpty {
                        Task { await configManager.fetchConfigs() }
                    }
                }
            }
            
            // Target Audience
            VStack(alignment: .leading, spacing: 16) {
                Text("Hedef Kitle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    AudienceCard(title: "Herkese Açık", subtitle: "Herkes görebilir ve katılabilir.", icon: "globe", isSelected: targetAudience == "Herkese Açık") { targetAudience = "Herkese Açık" }
                    AudienceCard(title: "Topluluk İçi", subtitle: "Sadece topluluk üyeleri görebilir.", icon: "person.2", isSelected: targetAudience == "Topluluk İçi") { targetAudience = "Topluluk İçi" }
                    AudienceCard(title: "Özel", subtitle: "Sadece davet ettiğiniz kişiler görebilir.", icon: "lock", isSelected: targetAudience == "Özel") { targetAudience = "Özel" }
                }
            }
        }
    }
    
    private var step2Questions: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                ZStack {
                    Circle().fill(Color.purple.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: "questionmark.circle").foregroundColor(.purple)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Anket Soruları").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text("Anketinize sorular ekleyin ve yanıt seçeneklerini düzenleyin.").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text("Soru: \(questions.count)").font(.system(size: 11)).padding(.horizontal, 10).padding(.vertical, 5).background(Color.white.opacity(0.05)).cornerRadius(8)
            }
            
            ForEach(0..<questions.count, id: \.self) { index in
                QuestionEditCard(question: $questions[index], number: index + 1)
            }
            
            Button(action: { questions.append(DraftQuestion(text: "", options: ["", ""], type: .singleChoice)) }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Soru Ekle")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
        }
    }
    
    private var step3Settings: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                ZStack {
                    Circle().fill(Color.purple.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: "gearshape").foregroundColor(.purple)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Anket Ayarları").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text("Anketinizin davranışını ve görünürlüğünü özelleştirin.").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            }
            
            // Katılım Hedefi
            VStack(alignment: .leading, spacing: 16) {
                Text("Katılım Hedefi").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                HStack(spacing: 12) {
                    AudienceCard(title: "Herkese Açık", subtitle: "Herkes görebilir ve katılabilir.", icon: "globe", isSelected: targetAudience == "Herkese Açık") { targetAudience = "Herkese Açık" }
                    AudienceCard(title: "Topluluk İçi", subtitle: "Sadece topluluk üyeleri görebilir.", icon: "person.2", isSelected: targetAudience == "Topluluk İçi") { targetAudience = "Topluluk İçi" }
                    AudienceCard(title: "Özel", subtitle: "Sadece davet ettiğiniz kişiler görebilir.", icon: "lock", isSelected: targetAudience == "Özel") { targetAudience = "Özel" }
                }
            }
            
            // Katılım Limiti
            VStack(alignment: .leading, spacing: 12) {
                Text("Katılım Limiti (İsteğe bağlı)").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                HStack(spacing: 20) {
                    RadioButtonField(id: "unlimited", label: "Sınırsız katılım", isSelected: true)
                    RadioButtonField(id: "limit", label: "Katılım limiti belirle", isSelected: false)
                }
                
                TextField("Katılım limiti", text: .constant("1000"))
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Sonuçların Görünürlüğü
            VStack(alignment: .leading, spacing: 12) {
                Text("Sonuçların Görünürlüğü").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                VStack(alignment: .leading, spacing: 16) {
                    RadioButtonField(id: "immediate", label: "Kapanır kapanmaz herkese göster", isSelected: true, sublabel: "Anket bittiği anda sonuçlar herkes tarafından görülebilir.")
                    RadioButtonField(id: "closed", label: "Katılımcılara kapandıktan sonra göster", isSelected: false, sublabel: "Anket bittiğinde yalnızca katılımcılar sonuçları görebilir.")
                    RadioButtonField(id: "never", label: "Hiç sonuç gösterme", isSelected: false, sublabel: "Sonuçlar yalnızca siz tarafınızdan görülebilir.")
                }
            }
            
            // Diğer Ayarlar
            VStack(alignment: .leading, spacing: 12) {
                Text("Diğer Ayarlar").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                VStack(spacing: 16) {
                    SettingsToggle(title: "Katılımcıların yanıtlarını değiştirmesine izin ver", isOn: .constant(true))
                    SettingsToggle(title: "Bir yanıt seçmeden ankete geçmeyi engelle", isOn: .constant(true))
                }
            }
        }
    }
    
    private var bottomActions: some View {
        VStack(spacing: 12) {
            Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1)
            
            HStack(spacing: 16) {
                if currentStep > 1 {
                    Button(action: { withAnimation { currentStep -= 1 } }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Geri")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Taslak Olarak Kaydet")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                
                Button(action: { if currentStep < 4 { withAnimation { currentStep += 1 } } }) {
                    HStack {
                        Text(currentStep == 4 ? "Yayınla" : "Devam Et")
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
            .padding(.bottom, 30)
            
            HStack(spacing: 8) {
                Image(systemName: "lock.fill").font(.system(size: 10))
                Text("Taslaklarınız sadece sizin tarafınızdan görülebilir.").font(.system(size: 10))
            }
            .foregroundColor(AppColors.textSecondary)
            .padding(.bottom, 10)
        }
        .background(AppColors.background)
    }
}

// Support Views for Create Survey
struct StepperItem: View {
    let number: Int
    let title: String
    let isCurrent: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.purple : (isCurrent ? Color.purple.opacity(0.2) : Color.white.opacity(0.05)))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isCurrent ? .purple : AppColors.textSecondary)
                }
            }
            .overlay(
                Circle().stroke(isCurrent ? Color.purple : Color.clear, lineWidth: 1)
            )
            
            Text(title)
                .font(.system(size: 10, weight: isCurrent ? .bold : .medium))
                .foregroundColor(isCurrent ? .purple : AppColors.textSecondary)
        }
    }
}

struct AudienceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.purple)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                    Text(subtitle)
                        .font(.system(size: 10))
                        .multilineTextAlignment(.leading)
                        .opacity(0.7)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(isSelected ? Color.purple.opacity(0.1) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 1)
            )
            .foregroundColor(.white)
        }
    }
}

struct DraftQuestion {
    var text: String
    var options: [String]
    var type: SurveyQuestion.QuestionType
    var isRequired: Bool = true
    var allowMultiple: Bool = false
}

struct QuestionEditCard: View {
    @Binding var question: DraftQuestion
    let number: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(number). Soru").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text("(Zorunlu)").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                Spacer()
                Image(systemName: "line.3.horizontal").foregroundColor(AppColors.textSecondary)
            }
            
            TextField("Sorunuzu buraya yazın...", text: $question.text)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Yanıt Seçenekleri").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    Spacer()
                    Button("Seçenek Ekle") {
                        question.options.append("")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 10).padding(.vertical, 5).background(Color.purple.opacity(0.1)).cornerRadius(6)
                }
                
                ForEach(0..<question.options.count, id: \.self) { i in
                    HStack {
                        Image(systemName: question.type == .singleChoice ? "circle" : "square")
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextField("Seçenek \(i + 1)", text: $question.options[i])
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal").foregroundColor(AppColors.textSecondary)
                        Button(action: { if question.options.count > 2 { question.options.remove(at: i) } }) {
                            Image(systemName: "trash").foregroundColor(.red.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(10)
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                Toggle("Çoklu yanıt verilebilir", isOn: $question.allowMultiple)
                    .font(.system(size: 13))
                Spacer()
                Toggle("Zorunlu soru", isOn: $question.isRequired)
                    .font(.system(size: 13))
            }
            .foregroundColor(.white)
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct RadioButtonField: View {
    let id: String
    let label: String
    let isSelected: Bool
    var sublabel: String? = nil
    
    var body: some View {
        HStack(alignment: sublabel != nil ? .top : .center, spacing: 12) {
            ZStack {
                Circle().stroke(isSelected ? Color.purple : Color.white.opacity(0.3), lineWidth: 2).frame(width: 20, height: 20)
                if isSelected {
                    Circle().fill(Color.purple).frame(width: 12, height: 12)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                if let sub = sublabel {
                    Text(sub).font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title).font(.system(size: 13)).foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
    }
}
