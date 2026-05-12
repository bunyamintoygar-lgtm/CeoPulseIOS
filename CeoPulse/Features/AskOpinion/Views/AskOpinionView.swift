import SwiftUI
import PhotosUI

struct AskOpinionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = CreateOpinionViewModel()
    
    // Pickers State
    @State private var selectedItem: PhotosPickerItem?
    @State private var isFileImporterPresented = false
    @State private var isLinkAlertPresented = false
    @State private var linkInput = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { 
                    if viewModel.currentStep > 1 {
                        viewModel.previousStep()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.purple)
                    Text("ao_title".localized())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        Text("save".localized())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Subtitle
                    Text("ao_subtitle".localized())
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 20)
                    
                    // Stepper
                    AskOpinionStepper(currentStep: viewModel.currentStep)
                        .padding(.horizontal, 20)
                    
                    if viewModel.currentStep == 1 {
                        stepOneView
                    } else if viewModel.currentStep == 2 {
                        stepTwoView
                    } else if viewModel.currentStep == 3 {
                        stepThreeView
                    } else {
                        stepFourView
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                    }
                    
                    // Action Button
                    Button(action: {
                        viewModel.nextStep()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(viewModel.currentStep == 4 ? "Yayınla" : "continue".localized())
                                    .font(.system(size: 16, weight: .bold))
                                Image(systemName: viewModel.currentStep == 4 ? "checkmark.circle.fill" : "arrow.right")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
                        .cornerRadius(16)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onChange(of: viewModel.isSuccess) { oldValue, newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            Task {
                await ConfigManager.shared.fetchConfigs()
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    // In a real app, upload to Supabase Storage and get URL
                    // For now, we simulate with a dummy URL
                    viewModel.addImage(name: "Görsel", url: "photo_selected.png")
                }
            }
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.pdf, .text, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.addDocument(name: url.lastPathComponent, url: url.absoluteString)
                }
            case .failure(let error):
                print("File selection error: \(error)")
            }
        }
        .alert("Link Ekle", isPresented: $isLinkAlertPresented) {
            TextField("https://...", text: $linkInput)
                .textInputAutocapitalization(.never)
            Button("İptal", role: .cancel) { linkInput = "" }
            Button("Ekle") {
                if !linkInput.isEmpty {
                    viewModel.addLink(url: linkInput)
                    linkInput = ""
                }
            }
        } message: {
            Text("Paylaşmak istediğiniz web adresini giriniz.")
        }
    }
    
    // MARK: - Steps
    
    private var stepOneView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("ao_field_title".localized() + " *")
                    Image(systemName: "questionmark.circle")
                    Spacer()
                    Text("\(viewModel.title.count)/120")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                
                TextField("ao_field_title_placeholder".localized(), text: $viewModel.title)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            
            // Description
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("ao_field_desc".localized() + " *")
                    Image(systemName: "questionmark.circle")
                    Spacer()
                    Text("\(viewModel.opinionDescription.count)/1500")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                
                TextEditor(text: $viewModel.opinionDescription)
                    .padding(8)
                    .frame(height: 120)
                    .scrollContentBackground(.hidden)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            
            // Question Type (Moved from Step 2)
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("ao_type_title".localized())
                    Image(systemName: "questionmark.circle")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 12) {
                    AskOpinionTypeCard(icon: "bubble.left.and.bubble.right", title: "ao_type_general".localized(), description: "ao_type_general_desc".localized(), isSelected: viewModel.selectedType == 0) { viewModel.selectedType = 0 }
                    AskOpinionTypeCard(icon: "scalemass", title: "ao_type_compare".localized(), description: "ao_type_compare_desc".localized(), isSelected: viewModel.selectedType == 1) { viewModel.selectedType = 1 }
                    AskOpinionTypeCard(icon: "lightbulb", title: "ao_type_solution".localized(), description: "ao_type_solution_desc".localized(), isSelected: viewModel.selectedType == 2) { viewModel.selectedType = 2 }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var stepTwoView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("ao_add_info".localized() + " (\("ao_optional".localized()))")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
            
            // Attachment Buttons
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    AttachmentButton(icon: "doc.text.fill", title: "ao_add_doc".localized(), desc: "ao_add_doc_desc".localized()) {
                        isFileImporterPresented = true
                    }
                    AttachmentButton(icon: "link", title: "ao_add_link".localized(), desc: "ao_add_link_desc".localized()) {
                        isLinkAlertPresented = true
                    }
                }
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        AttachmentButton(icon: "photo.fill", title: "ao_add_image".localized(), desc: "ao_add_image_desc".localized()) {}
                            .allowsHitTesting(false)
                    }
                    AttachmentButton(icon: "chart.bar.xaxis", title: "ao_add_survey".localized(), desc: "ao_add_survey_desc".localized()) {
                        viewModel.addSurvey()
                    }
                }
            }
            
            // List of added attachments
            if !viewModel.attachments.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Eklenen Öğeler")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    ForEach(Array(viewModel.attachments.enumerated()), id: \.offset) { index, attachment in
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: getIconForType(attachment.type))
                                    .foregroundColor(.purple)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(attachment.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    if let url = attachment.url {
                                        Text(url)
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { viewModel.removeAttachment(at: index) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.8))
                                        .font(.system(size: 14))
                                }
                            }
                            
                            // Premium Survey Editor (Matching Image)
                            if attachment.type == "survey", let survey = attachment.survey {
                                PremiumSurveyEditor(
                                    survey: survey,
                                    attachmentId: attachment.id,
                                    viewModel: viewModel
                                )
                            }
                        }
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
    }
                        }
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func getIconForType(_ type: String) -> String {
        switch type {
        case "doc": return "doc.text.fill"
        case "image": return "photo.fill"
        case "link": return "link"
        case "survey": return "chart.bar.xaxis"
        default: return "paperclip"
        }
    }
    
    private var stepThreeView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ao_select_categories".localized())
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
            
            // Category Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("ao_search_category_placeholder".localized(), text: $viewModel.categorySearchText)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
            .padding(12)
            .background(AppColors.surface)
            .cornerRadius(12)
            
            // Categories Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(ConfigManager.shared.opinionCategories.filter {
                        viewModel.categorySearchText.isEmpty || $0.name.localizedCaseInsensitiveContains(viewModel.categorySearchText)
                    }, id: \.id) { category in
                        CategorySelectCard(
                            title: category.name,
                            icon: category.icon ?? "tag",
                            isSelected: viewModel.category == category.id,
                            action: { viewModel.category = category.id }
                        )
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var stepFourView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("ao_target_title".localized())
                    Image(systemName: "questionmark.circle")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 12) {
                    AskOpinionTypeCard(icon: "person.2.fill", title: "ao_target_all".localized(), description: "ao_target_all_desc".localized(), isSelected: viewModel.selectedTarget == 0) { viewModel.selectedTarget = 0 }
                    AskOpinionTypeCard(icon: "star.bubble.fill", title: "ao_target_experts".localized(), description: "ao_target_experts_desc".localized(), isSelected: viewModel.selectedTarget == 1) { viewModel.selectedTarget = 1 }
                    AskOpinionTypeCard(icon: "person.crop.circle.badge.plus", title: "ao_target_specific".localized(), description: "ao_target_specific_desc".localized(), isSelected: viewModel.selectedTarget == 2) { viewModel.selectedTarget = 2 }
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("ao_privacy_title".localized())
                    Image(systemName: "questionmark.circle")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 12) {
                    PrivacyOptionCard(title: "ao_privacy_public".localized(), desc: "ao_privacy_public_desc".localized(), isSelected: viewModel.selectedPrivacy == 0) { viewModel.selectedPrivacy = 0 }
                    PrivacyOptionCard(title: "ao_privacy_community".localized(), desc: "ao_privacy_community_desc".localized(), isSelected: viewModel.selectedPrivacy == 1) { viewModel.selectedPrivacy = 1 }
                    PrivacyOptionCard(title: "ao_privacy_private".localized(), desc: "ao_privacy_private_desc".localized(), isSelected: viewModel.selectedPrivacy == 2) { viewModel.selectedPrivacy = 2 }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct AttachmentButton: View {
    let icon: String
    let title: String
    let desc: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(.purple)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Text(desc)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            }
            .padding(12)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
}

struct PrivacyOptionCard: View {
    let title: String
    let desc: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .stroke(isSelected ? .purple : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .fill(isSelected ? .purple : Color.clear)
                                .frame(width: 10, height: 10)
                        )
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Text(desc)
                        .font(.system(size: 9))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 90)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct CategorySelectCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.purple.opacity(0.1) : Color.white.opacity(0.05))
                            .frame(width: 32, height: 32)
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(isSelected ? .purple : .white)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 16))
                    }
                }
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct PremiumSurveyEditor: View {
    var survey: OpinionSurveyAttachment
    let attachmentId: String
    @ObservedObject var viewModel: CreateOpinionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Soru (Zorunlu)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                TextField("Anket Sorusu...", text: Binding(
                    get: { survey.question },
                    set: { newQuestion in
                        if let index = viewModel.attachments.firstIndex(where: { $0.id == attachmentId }) {
                            viewModel.attachments[index].survey?.question = newQuestion
                        }
                    }
                ))
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
                .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Yanıt Seçenekleri")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Button(action: { viewModel.addSurveyOption(attachmentId: attachmentId) }) {
                        Text("Seçenek Ekle")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                ForEach(0..<survey.options.count, id: \.self) { optIndex in
                    HStack(spacing: 12) {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                            .frame(width: 18, height: 18)
                        
                        TextField("Seçenek \(optIndex + 1)", text: Binding(
                            get: { survey.options[optIndex] },
                            set: { viewModel.updateSurveyOption(attachmentId: attachmentId, optionIndex: optIndex, text: $0) }
                        ))
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.gray.opacity(0.5))
                        
                        if survey.options.count > 2 {
                            Button(action: { viewModel.removeSurveyOption(attachmentId: attachmentId, optionIndex: optIndex) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.05), lineWidth: 1))
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            VStack(spacing: 12) {
                Toggle(isOn: Binding(
                    get: { survey.allowMultiple },
                    set: { _ in viewModel.toggleSurveyMultiple(attachmentId: attachmentId) }
                )) {
                    Text("Çoklu yanıt verilebilir")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .tint(.purple)
                
                Toggle(isOn: Binding(
                    get: { survey.isRequired },
                    set: { _ in viewModel.toggleSurveyRequired(attachmentId: attachmentId) }
                )) {
                    Text("Zorunlu soru")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .tint(.purple)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1))
    }
}
