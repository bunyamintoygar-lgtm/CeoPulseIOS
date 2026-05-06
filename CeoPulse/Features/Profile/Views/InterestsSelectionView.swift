import SwiftUI

struct InterestsSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var configManager = ConfigManager.shared
    @State private var selectedInterests: Set<String> = []
    @State private var searchText = ""
    
    // Helper to map icons based on title
    private func iconForInterest(_ title: String) -> String {
        switch title {
        case "Girişimcilik": return "rocket"
        case "Liderlik": return "chart.bar.fill"
        case "İnovasyon": return "lightbulb"
        case "Yönetim": return "person.2.fill"
        case "Finans": return "dollarsign.circle"
        case "Pazarlama": return "megaphone"
        case "Strateji": return "chart.pie"
        case "Kişisel Gelişim": return "brain.headset"
        case "Teknoloji": return "globe"
        case "Sürdürülebilirlik": return "leaf"
        case "Yatırım": return "hand.raised"
        case "İnsan Kaynakları": return "building.2"
        case "E-ticaret": return "cart"
        case "Siber Güvenlik": return "lock.shield"
        case "Markalaşma": return "bookmark"
        default: return "star"
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Section
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("interests_title", comment: ""))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text(NSLocalizedString("interests_subtitle", comment: ""))
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Counter & Selection Info
                        HStack {
                            Text("\(selectedInterests.count)/10")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(selectedInterests.count >= 3 ? .green : .orange)
                            
                            Spacer()
                            
                            Text(NSLocalizedString("interests_min_max_info", comment: ""))
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 4)
                        
                        // Flow Layout for Interests
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.purple)
                                Spacer()
                            }
                            .padding(.top, 40)
                        } else {
                            FlowLayout(spacing: 10) {
                                ForEach(interests, id: \.id) { interest in
                                    InterestTag(
                                        title: configManager.getLocalizedInterest(interest),
                                        isSelected: selectedInterests.contains(interest),
                                        onTap: { toggleInterest(interest) }
                                    )
                                }
                            }
                        }
                        
                        // Other Areas / Search
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("other_areas", comment: ""))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppColors.textSecondary)
                                TextField("", text: $searchText, prompt: Text(NSLocalizedString("search_area_placeholder", comment: "")).foregroundColor(AppColors.textSecondary))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.textSecondary)
                                    .font(.system(size: 12))
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        
                        // Selected Summary
                        if !selectedInterests.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("\(selectedInterests.count) / 10")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(NSLocalizedString("interests_min_max_info", comment: ""))
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                FlowLayout(spacing: 8, data: Array(selectedInterests)) { interest in
                                    SelectedInterestTag(title: configManager.getLocalizedInterest(interest)) {
                                        selectedInterests.remove(interest)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
                // Footer
                VStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Text(NSLocalizedString("button_continue", comment: ""))
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedInterests.count >= 3 ? Color(hex: "6C38FF") : Color.gray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .disabled(selectedInterests.count < 3)
                    .padding(24)
                }
                .background(AppColors.background)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchInterests()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
            Spacer()
            Image("ceopulse_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private func fetchInterests() {
        self.isLoading = true
        Task {
            await configManager.fetchConfigs()
            self.interests = configManager.interestsList
            self.isLoading = false
        }
    }
    
    private func toggleInterest(_ interest: LocalizedValue) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            if selectedInterests.count < 10 {
                selectedInterests.insert(interest)
            }
        }
    }
}

// MARK: - Components

struct Interest: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct InterestCard: View {
    let interest: Interest
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: interest.icon)
                        .font(.system(size: 20))
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 20, height: 20)
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.purple)
                                .background(Circle().fill(.white))
                        }
                    }
                }
                
                Text(interest.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(isSelected ? Color.purple.opacity(0.1) : Color.white.opacity(0.03))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .foregroundColor(isSelected ? .purple : .white)
    }
}

struct SelectedInterestTag: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white)
            
            Button(action: action) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.purple.opacity(0.2))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.purple.opacity(0.3), lineWidth: 1))
    }
}

// Helper for wrapping tags
struct FlowLayout: View {
    var spacing: CGFloat
    var content: [AnyView]
    
    init<Data: Collection, Content: View>(spacing: CGFloat = 8, data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.spacing = spacing
        self.content = data.map { AnyView(content($0)) }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            var width = CGFloat.zero
            var height = CGFloat.zero
            
            ForEach(0..<content.count, id: \.self) { index in
                content[index]
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > 300) {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if index == content.count - 1 {
                            width = 0 // last item
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { d in
                        let result = height
                        if index == content.count - 1 {
                            height = 0 // last item
                        }
                        return result
                    }
            }
        }
    }
}
