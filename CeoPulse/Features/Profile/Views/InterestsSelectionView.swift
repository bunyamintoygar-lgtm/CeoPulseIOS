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
                            Text("İlgi Alanlarınızı Seçin")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("Size özel içerik ve etkinlik önerileri almak için ilgi alanlarınızı belirleyin.")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.purple)
                            Text("En az 3, en fazla 10 ilgi alanı seçebilirsiniz.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple.opacity(0.1), lineWidth: 1))
                        
                        // Popular Areas Grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Popüler Alanlar")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            let displayInterests = configManager.interestsList.map { 
                                Interest(title: $0, icon: iconForInterest($0)) 
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(displayInterests) { interest in
                                    InterestCard(interest: interest, isSelected: selectedInterests.contains(interest.title)) {
                                        toggleInterest(interest.title)
                                    }
                                }
                            }
                        }
                        
                        // Other Areas / Search
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Diğer Alanlar")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppColors.textSecondary)
                                TextField("", text: $searchText, prompt: Text("Başka bir ilgi alanı ekleyin").foregroundColor(AppColors.textSecondary))
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
                                    Text("Seçilen \(selectedInterests.count) alan")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(selectedInterests.count) / 10")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                FlowLayout(spacing: 8, data: Array(selectedInterests)) { interest in
                                    SelectedInterestTag(title: interest) {
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
                            Text("Devam Et")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedInterests.count >= 3 ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
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
            Task {
                await configManager.fetchConfigs()
            }
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
    
    private func toggleInterest(_ title: String) {
        if selectedInterests.contains(title) {
            selectedInterests.remove(title)
        } else if selectedInterests.count < 10 {
            selectedInterests.insert(title)
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
