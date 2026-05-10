import SwiftUI
import Supabase

struct CreateSurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 1
    var onPublish: (() -> Void)? = nil
    var surveyToEdit: Survey? = nil
    
    // Step 1: Details
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: SurveyCategory?
    @State private var targetAudience = NSLocalizedString("ao_privacy_public", comment: "")
    @State private var hasEndDate = true // Default to true as per new 3-month rule
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    
    private var maxEndDate: Date {
        Calendar.current.date(byAdding: .month, value: 3, to: startDate) ?? startDate
    }
    @State private var isGeneratingAI = false
    @State private var isPublishing = false
    @State private var errorMessage: String?
    @State private var showingCategoryPicker = false
    
    // Step 3 Settings
    @State private var participationLimitType = "unlimited" // "unlimited" or "limit"
    @State private var participationLimit = "1000"
    @State private var resultsVisibility = "immediate" // "immediate", "closed", "never"
    @State private var allowChangeResponse = true
    @State private var isRequiredToAnswer = true
    @State private var isAnonymous = false
    
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
        DraftQuestion(text: "", options: [NSLocalizedString("ao_field_desc_placeholder", comment: "") + " 1", NSLocalizedString("ao_field_desc_placeholder", comment: "") + " 2"], type: .singleChoice)
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                headerView
                
                // Stepper
                surveyStepper
                
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.octagon.fill")
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                        Button(action: { errorMessage = nil }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
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
        .onChange(of: title) { _, _ in saveDraftSilently() }
        .onChange(of: description) { _, _ in saveDraftSilently() }
        .onChange(of: selectedCategory) { _, _ in saveDraftSilently() }
        .onChange(of: questions) { _, _ in saveDraftSilently() }
        .onChange(of: targetAudience) { _, _ in saveDraftSilently() }
        .onChange(of: endDate) { _, _ in saveDraftSilently() }
        .onChange(of: participationLimit) { _, _ in saveDraftSilently() }
        .onChange(of: participationLimitType) { _, _ in saveDraftSilently() }
        .onChange(of: resultsVisibility) { _, _ in saveDraftSilently() }
        .onChange(of: allowChangeResponse) { _, _ in saveDraftSilently() }
        .onChange(of: isRequiredToAnswer) { _, _ in saveDraftSilently() }
        .onChange(of: isAnonymous) { _, _ in saveDraftSilently() }
        .onAppear {
            if let survey = surveyToEdit {
                loadSurveyForEditing(survey)
            } else {
                checkForResumeDraft()
            }
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerSheet(categories: configManager.surveyCategories, selectedCategory: $selectedCategory)
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
                    Text(surveyToEdit == nil ? LocalizedStringKey("survey_create_nav_title") : LocalizedStringKey("survey_edit_title"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                Text(surveyToEdit == nil ? LocalizedStringKey("survey_create_subtitle") : LocalizedStringKey("survey_edit_subtitle"))
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
            StepperItem(number: 1, title: NSLocalizedString("survey_step_details", comment: ""), isCurrent: currentStep == 1, isCompleted: currentStep > 1)
            line
            StepperItem(number: 2, title: NSLocalizedString("survey_step_questions", comment: ""), isCurrent: currentStep == 2, isCompleted: currentStep > 2)
            line
            StepperItem(number: 3, title: NSLocalizedString("survey_step_settings", comment: ""), isCurrent: currentStep == 3, isCompleted: currentStep > 3)
            line
            StepperItem(number: 4, title: NSLocalizedString("survey_create_publish", comment: ""), isCurrent: currentStep == 4, isCompleted: currentStep > 4)
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
                Text(LocalizedStringKey("survey_details_section"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(NSLocalizedString("survey_field_title_label", comment: "")) *").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    ZStack(alignment: .trailing) {
                        TextField(LocalizedStringKey("survey_field_title_placeholder"), text: $title)
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
                    Text(LocalizedStringKey("survey_field_desc_label")).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
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
                Text(LocalizedStringKey("survey_field_category_label")).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                
                Button(action: { showingCategoryPicker = true }) {
                    HStack {
                        Image(systemName: selectedCategory?.icon ?? "square.grid.2x2")
                        Text(selectedCategory?.name ?? NSLocalizedString("survey_field_category_placeholder", comment: ""))
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .foregroundColor(selectedCategory == nil ? AppColors.textSecondary : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedCategory == nil && errorMessage != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                }
                .onAppear {
                    if configManager.surveyCategories.isEmpty {
                        Task { await configManager.fetchConfigs() }
                    }
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
                    Text(LocalizedStringKey("survey_field_questions_label")).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text(LocalizedStringKey("survey_questions_subtitle")).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text(String(format: NSLocalizedString("survey_question_count", comment: ""), questions.count)).font(.system(size: 11)).padding(.horizontal, 10).padding(.vertical, 5).background(Color.white.opacity(0.05)).cornerRadius(8)
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
                        Text(isGeneratingAI ? LocalizedStringKey("survey_ai_generating") : LocalizedStringKey("survey_ai_wizard"))
                            .font(.system(size: 14, weight: .bold))
                        Text(LocalizedStringKey("survey_ai_wizard_desc"))
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
            
            ForEach(questions) { question in
                QuestionEditCard(
                    question: binding(for: question.id),
                    number: (questions.firstIndex(where: { $0.id == question.id }) ?? 0) + 1
                ) {
                    withAnimation(.spring()) {
                        if questions.count > 1 {
                            if let index = questions.firstIndex(where: { $0.id == question.id }) {
                                questions.remove(at: index)
                                saveDraftSilently()
                            }
                        } else {
                            // Reset if it's the last one
                            if let index = questions.firstIndex(where: { $0.id == question.id }) {
                                questions[index] = DraftQuestion(text: "", options: ["", ""], type: .singleChoice)
                                saveDraftSilently()
                            }
                        }
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
                    Text(LocalizedStringKey("survey_add_question"))
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
                    Text(LocalizedStringKey("survey_settings_label")).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text(LocalizedStringKey("personalize_subtitle")).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            }
            
            // Katılım Hedefi
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizedStringKey("ao_target_title")).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                HStack(spacing: 12) {
                    let steps = [
                        NSLocalizedString("survey_step_details", comment: ""),
                        NSLocalizedString("survey_step_questions", comment: ""),
                        NSLocalizedString("survey_step_settings", comment: ""),
                        NSLocalizedString("survey_step_preview", comment: "")
                    ]
                    AudienceCard(title: NSLocalizedString("ao_privacy_public", comment: ""), subtitle: NSLocalizedString("ao_privacy_public_desc", comment: ""), icon: "globe", isSelected: targetAudience == NSLocalizedString("ao_privacy_public", comment: "")) { targetAudience = NSLocalizedString("ao_privacy_public", comment: "") }
                    AudienceCard(title: NSLocalizedString("ao_privacy_community", comment: ""), subtitle: NSLocalizedString("ao_privacy_community_desc", comment: ""), icon: "person.2", isSelected: targetAudience == NSLocalizedString("ao_privacy_community", comment: "")) { targetAudience = NSLocalizedString("ao_privacy_community", comment: "") }
                    AudienceCard(title: NSLocalizedString("ao_privacy_private", comment: ""), subtitle: NSLocalizedString("ao_privacy_private_desc", comment: ""), icon: "lock", isSelected: targetAudience == NSLocalizedString("ao_privacy_private", comment: "")) { targetAudience = NSLocalizedString("ao_privacy_private", comment: "") }
                }
            }
            
            // Katılım Limiti
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizedStringKey("survey_setting_participation_limit")).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                HStack(spacing: 20) {
                    RadioButtonField(id: "unlimited", label: NSLocalizedString("survey_setting_unlimited", comment: ""), isSelected: participationLimitType == "unlimited") {
                        participationLimitType = "unlimited"
                    }
                    RadioButtonField(id: "limit", label: NSLocalizedString("survey_setting_limit_define", comment: ""), isSelected: participationLimitType == "limit") {
                        participationLimitType = "limit"
                    }
                }
                
                if participationLimitType == "limit" {
                    TextField(LocalizedStringKey("survey_setting_participation_limit"), text: $participationLimit)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
            
            // Sonuçların Görünürlüğü
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizedStringKey("survey_setting_results")).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                VStack(alignment: .leading, spacing: 16) {
                    RadioButtonField(id: "immediate", label: NSLocalizedString("survey_setting_results_immediate", comment: ""), isSelected: resultsVisibility == "immediate", sublabel: NSLocalizedString("ao_privacy_public_desc", comment: "")) {
                        resultsVisibility = "immediate"
                    }
                    RadioButtonField(id: "closed", label: NSLocalizedString("survey_setting_results_closed", comment: ""), isSelected: resultsVisibility == "closed", sublabel: NSLocalizedString("ao_privacy_community_desc", comment: "")) {
                        resultsVisibility = "closed"
                    }
                    RadioButtonField(id: "never", label: NSLocalizedString("survey_setting_results_never", comment: ""), isSelected: resultsVisibility == "never", sublabel: NSLocalizedString("ao_privacy_private_desc", comment: "")) {
                        resultsVisibility = "never"
                    }
                }
            }
            
            // Diğer Ayarlar
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizedStringKey("survey_setting_advanced")).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                VStack(spacing: 12) {
                    SettingsToggle(title: NSLocalizedString("survey_setting_allow_change", comment: ""), icon: "arrow.left.arrow.right.circle", isOn: $allowChangeResponse)
                    SettingsToggle(title: NSLocalizedString("survey_setting_required", comment: ""), icon: "exclamationmark.circle", isOn: $isRequiredToAnswer)
                    SettingsToggle(title: NSLocalizedString("survey_setting_anonymous", comment: ""), icon: "eye.slash", isOn: $isAnonymous)
                }
            }
            
            // Bitiş Tarihi Ayarı
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(LocalizedStringKey("survey_setting_end_date"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(LocalizedStringKey("survey_setting_max_duration"))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(6)
                }
                
                VStack(spacing: 12) {
                    DatePicker(
                        NSLocalizedString("survey_setting_end_date", comment: ""),
                        selection: $endDate,
                        in: startDate...maxEndDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.purple)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                    .colorScheme(.dark)
                }
                
                Text(String(format: NSLocalizedString("survey_setting_auto_close_info", comment: ""), maxEndDate.formatted(date: .long, time: .omitted)))
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
                    Text(LocalizedStringKey("rt_view_summary")).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text(LocalizedStringKey("survey_final_ready_desc")).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
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
                    Text(title.isEmpty ? LocalizedStringKey("survey_field_title_label") : LocalizedStringKey(title))
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
                    Text(String(format: NSLocalizedString("survey_field_questions_label", comment: ""), questions.count))
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
                
                Text(LocalizedStringKey("survey_final_ready_title"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("survey_final_ready_desc"))
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
                            Text(LocalizedStringKey("button_back"))
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                    }
                }
                
                Button(action: { 
                    if currentStep == 1 {
                        let words = title.trimmingCharacters(in: .whitespacesAndNewlines)
                            .components(separatedBy: .whitespacesAndNewlines)
                            .filter { !$0.isEmpty }
                        
                        if words.count < 3 {
                            errorMessage = NSLocalizedString("survey_error_title_min_words", comment: "")
                            return
                        }
                        
                        if selectedCategory == nil {
                            errorMessage = NSLocalizedString("survey_error_category_required", comment: "")
                            showingCategoryPicker = true
                            return
                        }
                    }
                    
                    errorMessage = nil // Clear error if validated
                    
                    if currentStep < 4 { 
                        withAnimation { currentStep += 1 } 
                    } else {
                        publishSurvey()
                    }
                }) {
                    HStack {
                        if isPublishing {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 8)
                        }
                        
                        let buttonText: String = {
                            if currentStep < 4 {
                                return NSLocalizedString("continue", comment: "")
                            } else {
                                return surveyToEdit != nil ? NSLocalizedString("survey_update_publish", comment: "") : NSLocalizedString("survey_create_publish", comment: "")
                            }
                        }()
                        
                        Text(buttonText)
                        
                        if !isPublishing {
                            Image(systemName: currentStep < 4 ? "arrow.right" : "checkmark")
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "6C38FF"))
                    .cornerRadius(12)
                    .opacity(isPublishing ? 0.7 : 1.0)
                    .disabled(isPublishing)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            HStack(spacing: 8) {
                Image(systemName: "lock.fill").font(.system(size: 10))
                Text(LocalizedStringKey("survey_draft_privacy_info")).font(.system(size: 10))
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
                Text(LocalizedStringKey("survey_draft_resume_title"))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("survey_draft_resume_desc"))
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
                    Text(LocalizedStringKey("survey_draft_resume_button"))
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
                    Text(LocalizedStringKey("survey_draft_new_button"))
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
            step: currentStep,
            hasEndDate: hasEndDate,
            endDate: endDate,
            participationLimit: participationLimit,
            resultsVisibility: resultsVisibility,
            allowChangeResponse: allowChangeResponse,
            isRequired: isRequiredToAnswer,
            isAnonymous: isAnonymous
        )
    }
    
    private func resumeDraft() {
        if let draft = draftManager.loadDraft() {
            self.title = draft.title
            self.description = draft.description
            self.targetAudience = draft.targetAudience
            self.questions = draft.questions
            self.currentStep = draft.currentStep
            self.hasEndDate = draft.hasEndDate
            self.endDate = draft.endDate
            self.participationLimit = draft.participationLimit
            self.participationLimitType = draft.participationLimit == "unlimited" ? "unlimited" : "limit"
            self.resultsVisibility = draft.resultsVisibility
            self.allowChangeResponse = draft.allowChangeResponse
            self.isRequiredToAnswer = draft.isRequired
            self.isAnonymous = draft.isAnonymous
            
            // Category lookup
            if let catId = draft.categoryId {
                self.selectedCategory = configManager.surveyCategories.first(where: { $0.id == catId })
            }
        }
    }
    
    private func loadSurveyForEditing(_ survey: Survey) {
        self.title = survey.title
        self.description = survey.description ?? ""
        self.targetAudience = survey.targetAudience
        self.startDate = survey.startDate
        self.endDate = survey.endDate ?? Date()
        self.participationLimit = String(survey.participationLimit ?? 1000)
        self.participationLimitType = survey.participationLimit == nil ? "unlimited" : "limit"
        self.resultsVisibility = survey.resultVisibility.rawValue
        self.allowChangeResponse = survey.allowEditResponses
        self.isAnonymous = survey.isAnonymous
        
        if let catId = survey.categoryId {
            self.selectedCategory = configManager.surveyCategories.first(where: { $0.id == catId })
        }
        
        // Fetch questions and options
        Task {
            do {
                let fetchedQuestions = try await SurveyService.shared.fetchQuestions(for: survey.id)
                var draftQuestions: [DraftQuestion] = []
                
                for q in fetchedQuestions {
                    let options = try await SurveyService.shared.fetchOptions(for: q.id)
                    draftQuestions.append(DraftQuestion(
                        id: q.id,
                        text: q.questionText,
                        options: options.map { $0.optionText },
                        type: q.questionType == .singleChoice ? .singleChoice : .multipleChoice
                    ))
                }
                
                await MainActor.run {
                    self.questions = draftQuestions
                }
            } catch {
                print("Failed to load questions for editing: \(error)")
            }
        }
    }
    
    private func publishSurvey() {
        guard let category = selectedCategory else {
            errorMessage = "Lütfen bir kategori seçin."
            return
        }
        
        isPublishing = true
        errorMessage = nil
        
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let userId = session.user.id
                
                let surveyId = surveyToEdit?.id ?? UUID()
                
                // 1. Create/Update Survey Object
                let survey = Survey(
                    id: surveyId,
                    creatorId: userId,
                    title: title,
                    description: description.isEmpty ? nil : description,
                    categoryId: category.id,
                    coverImageUrl: surveyToEdit?.coverImageUrl,
                    targetAudience: targetAudience.lowercased() == "herkese açık" ? "public" : (targetAudience.lowercased() == "topluluk içi" ? "community" : "private"),
                    status: surveyToEdit?.status ?? .active,
                    rejectionReason: nil,
                    startDate: surveyToEdit?.startDate ?? Date(),
                    endDate: endDate,
                    isAnonymous: isAnonymous,
                    resultVisibility: resultsVisibility == "immediate" ? .immediate : (resultsVisibility == "closed" ? .after_closed : .never),
                    allowEditResponses: allowChangeResponse,
                    participationLimit: participationLimitType == "limit" ? Int(participationLimit) : nil,
                    createdAt: surveyToEdit?.createdAt ?? Date(),
                    language: Locale.current.language.languageCode?.identifier ?? "tr"
                )
                
                // 2. Prepare Questions & Options
                var dbQuestions: [SurveyQuestion] = []
                var dbOptionsMap: [UUID: [SurveyOption]] = [:]
                
                for (index, draftQ) in questions.enumerated() {
                    let qId = UUID()
                    let dbQ = SurveyQuestion(
                        id: qId,
                        surveyId: surveyId,
                        questionText: draftQ.text,
                        questionType: draftQ.type == .singleChoice ? .singleChoice : .multipleChoice,
                        isRequired: draftQ.isRequired ?? true,
                        maxSelections: draftQ.allowMultiple == true ? 10 : 1, // multiple choice logic
                        order: index
                    )
                    dbQuestions.append(dbQ)
                    
                    var qOptions: [SurveyOption] = []
                    for (optIndex, optText) in draftQ.options.enumerated() {
                        let dbOpt = SurveyOption(
                            id: UUID(),
                            questionId: qId,
                            optionText: optText,
                            order: optIndex
                        )
                        qOptions.append(dbOpt)
                    }
                    dbOptionsMap[qId] = qOptions
                }
                
                // 3. Save to Supabase
                if surveyToEdit != nil {
                    try await SurveyService.shared.updateSurvey(
                        survey: survey,
                        questions: dbQuestions,
                        options: dbOptionsMap
                    )
                } else {
                    try await SurveyService.shared.createSurvey(
                        survey: survey,
                        questions: dbQuestions,
                        options: dbOptionsMap
                    )
                }
                
                
                await MainActor.run {
                    isPublishing = false
                    draftManager.clearDraft()
                    onPublish?()
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("Publish error: \(error)")
                await MainActor.run {
                    isPublishing = false
                    errorMessage = "Anket yayınlanırken bir hata oluştu: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func binding(for id: UUID) -> Binding<DraftQuestion> {
        Binding(
            get: { 
                questions.first(where: { $0.id == id }) ?? DraftQuestion(text: "", options: [], type: .singleChoice)
            },
            set: { newValue in
                if let index = questions.firstIndex(where: { $0.id == id }) {
                    questions[index] = newValue
                }
            }
        )
    }
    
    private func checkForResumeDraft() {
        let isDefaultState = title.isEmpty && questions.count == 1 && (questions.first?.text.isEmpty ?? true)
        
        if draftManager.hasDraft() && isDefaultState {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showingResumeOverlay = true
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

struct DraftQuestion: Codable, Equatable, Identifiable {
    var id = UUID()
    var text: String
    var options: [String]
    var type: SurveyQuestion.QuestionType
    var isRequired: Bool? = true
    var allowMultiple: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case text, options, type, isRequired, allowMultiple
    }
}

struct QuestionEditCard: View {
    @Binding var question: DraftQuestion
    let number: Int
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirm = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Text("\(number)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.purple))
                        Text(LocalizedStringKey("survey_field_question")).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    }
                    Text((question.isRequired ?? true) ? "(\(NSLocalizedString("survey_required_label", comment: "")))" : "(\(NSLocalizedString("survey_optional_label", comment: "")))")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer() // Pushes delete button to the far right
                    
                    Button(action: {
                        hideKeyboard()
                        withAnimation(.spring()) { showingDeleteConfirm = true }
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.8))
                            .padding(8)
                            .background(Circle().fill(Color.red.opacity(0.1)))
                    }
                }
                
                TextField(LocalizedStringKey("survey_question_placeholder"), text: $question.text, axis: .vertical)
                    .font(.system(size: 14, weight: .medium)) // Reduced font size
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                    .foregroundColor(.white)
                    .lineLimit(1...4)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(LocalizedStringKey("survey_options_label")).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            withAnimation { question.options.append("") }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text(LocalizedStringKey("survey_add_option"))
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
                            
                            TextField("", text: $question.options[i])
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
                            Text(LocalizedStringKey("survey_allow_multiple")).font(.system(size: 13))
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
                            Text(LocalizedStringKey("survey_required_label")).font(.system(size: 13))
                        }
                    }
                    .tint(.purple)
                }
                .foregroundColor(.white)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
            
            // Premium Delete Confirmation Overlay
            if showingDeleteConfirm {
                Color.black.opacity(0.4)
                    .cornerRadius(16)
                    .transition(.opacity)
                
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                        .symbolEffect(.bounce, value: showingDeleteConfirm)
                    
                    VStack(spacing: 4) {
                        Text(LocalizedStringKey("survey_delete_question_title"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(LocalizedStringKey("survey_delete_question_desc"))
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring()) { showingDeleteConfirm = false }
                        }) {
                            Text(LocalizedStringKey("survey_create_cancel"))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.1)))
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                showingDeleteConfirm = false
                                onDelete()
                            }
                        }) {
                            Text(LocalizedStringKey("survey_delete_confirm"))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)))
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "1A1A20"))
                        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                )
                .padding(10)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .zIndex(10)
            }
        }
    }
}

struct RadioButtonField: View {
    let id: String
    let label: String
    let isSelected: Bool
    var sublabel: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: sublabel != nil ? .top : .center, spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.purple : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 12, height: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                    
                    if let sub = sublabel {
                        Text(sub)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(.plain)
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

struct CategoryPickerSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let categories: [SurveyCategory]
    @Binding var selectedCategory: SurveyCategory?
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text(LocalizedStringKey("survey_field_category_placeholder"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(categories) { category in
                            Button(action: {
                                selectedCategory = category
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedCategory?.id == category.id ? Color.purple.opacity(0.2) : Color.white.opacity(0.05))
                                            .frame(width: 44, height: 44)
                                        if let icon = category.icon {
                                            Image(systemName: icon)
                                                .foregroundColor(selectedCategory?.id == category.id ? .purple : .white)
                                        }
                                    }
                                    
                                    Text(category.name)
                                        .font(.system(size: 16, weight: selectedCategory?.id == category.id ? .bold : .medium))
                                        .foregroundColor(selectedCategory?.id == category.id ? .white : .white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    if selectedCategory?.id == category.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.purple)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(selectedCategory?.id == category.id ? 0.08 : 0.03)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedCategory?.id == category.id ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

