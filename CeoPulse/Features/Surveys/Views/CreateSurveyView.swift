import SwiftUI
import Supabase

struct CreateSurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 1
    
    // Step 1: Details
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: SurveyCategory?
    @State private var targetAudience = "Herkese Açık"
    @State private var hasEndDate = true // Default to true as per new 3-month rule
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    
    private var maxEndDate: Date {
        Calendar.current.date(byAdding: .month, value: 3, to: startDate) ?? startDate
    }
    @State private var isGeneratingAI = false
    
    private func generateAIQuestions() {
        guard !title.isEmpty else { return }
        isGeneratingAI = true
        
        Task {
            do {
                let languageCode = Locale.current.language.languageCode?.identifier ?? "tr"
                
                // Invoke function and get raw data using explicit decoder closure
                let responseData = try await SupabaseManager.shared.client.functions
                    .invoke("generate-survey-questions", 
                            options: .init(body: [
                                "title": title, 
                                "description": description,
                                "language": languageCode
                            ]),
                            decode: { data, _ in data }) // Updated to accept both Data and Response
                
                // Try to decode
                let decoder = JSONDecoder()
                
                // Debug log raw JSON
                if let jsonString = String(data: responseData, encoding: .utf8) {
                    print("AI Raw JSON Response: \(jsonString)")
                }
                
                do {
                    let response = try decoder.decode([DraftQuestion].self, from: responseData)
                    await MainActor.run {
                        withAnimation(.spring()) {
                            self.questions = response
                            self.isGeneratingAI = false
                            saveDraftSilently() // Save immediately after AI generation
                        }
                    }
                } catch {
                    print("AI decoding error: \(error)")
                    // If it's a single object with an "error" field, show that
                    if let errorObj = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let errMsg = errorObj["error"] as? String {
                        print("AI Edge Function Error: \(errMsg)")
                    }
                    await MainActor.run { self.isGeneratingAI = false }
                }
            } catch {
                print("AI invocation error: \(error)")
                
                // Try to extract detailed error message if it's an HTTP error
                if let functionsError = error as? FunctionsError,
                   case .httpError(let code, let data) = functionsError {
                    let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error body"
                    print("AI Function HTTP Error \(code): \(errorBody)")
                }
                
                await MainActor.run { self.isGeneratingAI = false }
            }
        }
    }
    
    @StateObject private var draftManager = SurveyDraftManager.shared
    
    private var hasChanges: Bool {
        // Only count as changes if title/desc is not empty OR questions are different from the single default blank question
        !title.isEmpty || !description.isEmpty || questions.count > 1 || (questions.count == 1 && !questions[0].text.isEmpty)
    }
    
    @StateObject private var configManager = ConfigManager.shared
    @State private var showingResumeOverlay = false
    
    // Step 2: Questions
    @State private var questions: [DraftQuestion] = [
        DraftQuestion(text: "", options: ["Seçenek 1", "Seçenek 2"], type: .singleChoice)
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
                        } else if currentStep == 4 {
                            step4Preview
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
                
                // Bottom Actions
                bottomActions
            }
            
            // Premium Resume Draft Overlay
            if showingResumeOverlay {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                resumeDraftOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: title) { saveDraftSilently() }
        .onChange(of: description) { saveDraftSilently() }
        .onChange(of: selectedCategory) { saveDraftSilently() }
        .onChange(of: questions) { saveDraftSilently() }
        .onChange(of: targetAudience) { saveDraftSilently() }
        .onAppear {
            if draftManager.hasDraft() && title.isEmpty && questions.count == 1 && questions[0].text.isEmpty {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showingResumeOverlay = true
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                if hasChanges {
                    saveDraftSilently()
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.square.fill.on.square.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.purple)
                        .symbolEffect(.bounce, value: currentStep)
                    Text("Yeni Anket Ekle")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Anketinizi oluşturun ve paylaşın.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Empty space for balance
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    
    private var surveyStepper: some View {
        HStack {
            StepperItem(number: 1, title: "Detay", isCurrent: currentStep == 1, isCompleted: currentStep > 1)
            line
            StepperItem(number: 2, title: "Sorular", isCurrent: currentStep == 2, isCompleted: currentStep > 2)
            line
            StepperItem(number: 3, title: "Ayarlar", isCurrent: currentStep == 3, isCompleted: currentStep > 3)
            line
            StepperItem(number: 4, title: "Yayınla", isCurrent: currentStep == 4, isCompleted: currentStep > 4)
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
                    ZStack(alignment: .trailing) {
                        TextField("Anket başlığını girin...", text: $title)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        
                        Text("\(title.count)/120")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.trailing, 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anket Açıklaması").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    ZStack(alignment: .bottomTrailing) {
                        TextEditor(text: $description)
                            .frame(height: 120)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.black)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        
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
            
            // AI Wizard Button
            Button(action: generateAIQuestions) {
                HStack(spacing: 12) {
                    if isGeneratingAI {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .symbolEffect(.bounce, options: .repeating)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isGeneratingAI ? "Sorular Hazırlanıyor..." : "AI Soru Sihirbazı")
                            .font(.system(size: 14, weight: .bold))
                        Text("Anket adına göre soruları otomatik oluştur")
                            .font(.system(size: 10))
                            .opacity(0.8)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .padding()
                .foregroundColor(.white)
                .background(
                    LinearGradient(colors: [Color(hex: "6C38FF"), .purple], startPoint: .leading, endPoint: .trailing)
                        .opacity(isGeneratingAI ? 0.6 : 1.0)
                )
                .cornerRadius(16)
                .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(isGeneratingAI || title.isEmpty)
            .opacity(title.isEmpty ? 0.5 : 1.0)
            
            ForEach(0..<questions.count, id: \.self) { index in
                QuestionEditCard(question: $questions[index], number: index + 1) {
                    if questions.count > 1 {
                        questions.remove(at: index)
                    } else {
                        // Reset if it's the last one
                        questions[index] = DraftQuestion(text: "", options: ["", ""], type: .singleChoice)
                    }
                }
            }
            
            Button(action: { 
                withAnimation(.spring()) {
                    questions.append(DraftQuestion(text: "", options: ["", ""], type: .singleChoice)) 
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Soru Ekle")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
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
                Text("Gelişmiş Seçenekler").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                VStack(spacing: 12) {
                    SettingsToggle(title: "Yanıtları değiştirmeye izin ver", icon: "arrow.left.arrow.right.circle", isOn: .constant(true))
                    SettingsToggle(title: "Yanıtlamayı zorunlu tut", icon: "exclamationmark.circle", isOn: .constant(true))
                    SettingsToggle(title: "Sonuçları anonimleştir", icon: "eye.slash", isOn: .constant(false))
                }
            }
            
            // Bitiş Tarihi Ayarı
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Anket Bitiş Tarihi")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Max 3 Ay")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(6)
                }
                
                VStack(spacing: 12) {
                    DatePicker(
                        "Bitiş Tarihi",
                        selection: $endDate,
                        in: Date()...maxEndDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.purple)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                    .colorScheme(.dark)
                }
                
                Text("Anketiniz en geç \(maxEndDate.formatted(date: .long, time: .omitted)) tarihinde otomatik olarak kapanacaktır.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private var step4Preview: some View {
        VStack(spacing: 24) {
            HStack {
                ZStack {
                    Circle().fill(Color.green.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: "eye.fill").foregroundColor(.green)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Son Önizleme").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text("Anketiniz yayınlandığında böyle görünecek.").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            }
            
            // Preview Card
            VStack(alignment: .leading, spacing: 20) {
                if let category = selectedCategory {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon ?? "tag")
                        Text(category.name)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.purple.opacity(0.2))
                    .foregroundColor(.purple)
                    .cornerRadius(6)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title.isEmpty ? "Anket Başlığı" : title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sorular (\(questions.count))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    ForEach(questions.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            Text("\(i + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                            Text(questions[i].text.isEmpty ? "Soru metni..." : questions[i].text)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.03)))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
            
            // Final Call to Action
            VStack(spacing: 16) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 60))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.purple)
                    .symbolEffect(.bounce, options: .repeating)
                
                Text("Anketiniz Yayına Hazır!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Yayınla butonuna bastığınızda tüm CEO'lar anketinize katılabilecek.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.vertical, 20)
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
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
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
    
    private var resumeDraftOverlay: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .symbolEffect(.bounce, options: .repeating)
            }
            
            VStack(spacing: 8) {
                Text("Yarım Kalan Anket")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Daha önce başladığınız bir anket taslağı bulundu. Kaldığınız yerden devam etmek ister misiniz?")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    resumeDraft()
                    withAnimation { showingResumeOverlay = false }
                }) {
                    Text("Taslaktan Devam Et")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [.purple, Color(hex: "6C38FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
                }
                
                Button(action: {
                    draftManager.clearDraft()
                    withAnimation { showingResumeOverlay = false }
                }) {
                    Text("Yeni Anket Başlat")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(hex: "121217"))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
        .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
    }
    
    private func saveDraftSilently() {
        draftManager.saveDraft(
            title: title,
            description: description,
            category: selectedCategory,
            audience: targetAudience,
            questions: questions,
            step: currentStep
        )
    }
    
    private func resumeDraft() {
        if let draft = draftManager.loadDraft() {
            self.title = draft.title
            self.description = draft.description
            self.targetAudience = draft.targetAudience
            self.questions = draft.questions
            self.currentStep = draft.currentStep
            // Category lookup
            if let catId = draft.categoryId {
                self.selectedCategory = configManager.surveyCategories.first(where: { $0.id == catId })
            }
        }
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
                    .frame(width: 28, height: 28)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .symbolEffect(.bounce, value: isCompleted)
                } else {
                    Text("\(number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isCurrent ? .purple : AppColors.textSecondary)
                }
            }
            .overlay(
                Circle()
                    .stroke(isCurrent ? Color.purple : Color.clear, lineWidth: 1)
                    .scaleEffect(isCurrent ? 1.2 : 1.0)
                    .opacity(isCurrent ? 0.5 : 0)
            )
            
            Text(title)
                .font(.system(size: 10, weight: isCurrent ? .bold : .medium))
                .foregroundColor(isCurrent ? .purple : AppColors.textSecondary)
        }
        .animation(.spring(), value: isCurrent)
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
                        .font(.system(size: 20))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(isSelected ? .purple : .white)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.purple)
                            .symbolEffect(.bounce, value: isSelected)
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
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple : Color.white.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(), value: isSelected)
            .foregroundColor(.white)
        }
    }
}

struct DraftQuestion: Codable, Equatable {
    var text: String
    var options: [String]
    var type: SurveyQuestion.QuestionType
    var isRequired: Bool? = true
    var allowMultiple: Bool? = false
}

struct QuestionEditCard: View {
    @Binding var question: DraftQuestion
    let number: Int
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Text("\(number)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color.purple))
                    Text("Soru").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                }
                Text((question.isRequired ?? true) ? "(Zorunlu)" : "(İsteğe Bağlı)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                Button(action: {
                    withAnimation { onDelete() }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(8)
                        .background(Circle().fill(Color.red.opacity(0.1)))
                }
            }
            
            TextField("Sorunuzu buraya yazın...", text: $question.text, axis: .vertical)
                .font(.system(size: 14, weight: .medium)) // Reduced font size
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                .foregroundColor(.white)
                .lineLimit(1...4)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Yanıt Seçenekleri").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        withAnimation { question.options.append("") }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Seçenek Ekle")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.purple.opacity(0.1)))
                    }
                }
                
                ForEach(0..<question.options.count, id: \.self) { i in
                    HStack {
                        Image(systemName: question.type == .singleChoice ? "circle.fill" : "checkmark.square.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.purple)
                        
                        TextField("Seçenek \(i + 1)", text: $question.options[i])
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { 
                            if question.options.count > 2 {
                                withAnimation { _ = question.options.remove(at: i) }
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .red.opacity(0.1))
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack(spacing: 20) {
                Toggle(isOn: Binding(
                    get: { question.allowMultiple ?? false },
                    set: { question.allowMultiple = $0 }
                )) {
                    HStack(spacing: 6) {
                        Image(systemName: "checklist")
                            .symbolRenderingMode(.hierarchical)
                        Text("Çoklu yanıt").font(.system(size: 13))
                    }
                }
                .tint(.purple)
                
                Toggle(isOn: Binding(
                    get: { question.isRequired ?? true },
                    set: { question.isRequired = $0 }
                )) {
                    HStack(spacing: 6) {
                        Image(systemName: "asterisk.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                        Text("Zorunlu").font(.system(size: 13))
                    }
                }
                .tint(.purple)
            }
            .foregroundColor(.white)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct RadioButtonField: View {
    let id: String
    let label: String
    let isSelected: Bool
    var sublabel: String? = nil
    
    var body: some View {
        HStack(alignment: sublabel != nil ? .top : .center, spacing: 14) {
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.purple : Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 22, height: 22)
                
                if isSelected {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 12, height: 12)
                        .symbolEffect(.bounce, value: isSelected)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                if let sub = sublabel {
                    Text(sub)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.purple.opacity(0.05) : Color.clear)
        )
        .contentShape(Rectangle())
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct SettingsToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.white.opacity(0.05)).frame(width: 36, height: 36)
                Image(systemName: icon)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.purple)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.purple)
                .labelsHidden()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
    }
}
