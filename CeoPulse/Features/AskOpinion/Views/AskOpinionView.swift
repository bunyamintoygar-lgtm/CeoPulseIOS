import SwiftUI

struct AskOpinionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = CreateOpinionViewModel()
    
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
    }
    
    // MARK: - Steps
    
    private var stepOneView: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                    .background(Color.black)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var stepTwoView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Question Type (Moved from Step 3)
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
            
            // Attachments
            VStack(alignment: .leading, spacing: 16) {
                Text("ao_add_info".localized() + " (\("ao_optional".localized()))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        AttachmentButton(icon: "doc.text.fill", title: "ao_add_doc".localized(), desc: "ao_add_doc_desc".localized())
                        AttachmentButton(icon: "link", title: "ao_add_link".localized(), desc: "ao_add_link_desc".localized())
                    }
                    HStack(spacing: 12) {
                        AttachmentButton(icon: "photo.fill", title: "ao_add_image".localized(), desc: "ao_add_image_desc".localized())
                        AttachmentButton(icon: "chart.bar.xaxis", title: "ao_add_survey".localized(), desc: "ao_add_survey_desc".localized())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
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
    
    var body: some View {
        Button(action: {}) {
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
