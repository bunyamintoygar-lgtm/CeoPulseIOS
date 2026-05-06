import SwiftUI

struct RoundtableView: View {
    @State private var selectedCategory = "Tümü"
    @State private var selectedTab = 0
    
    let categories = [
        ("Tümü", "square.grid.2x2.fill"),
        ("Teknoloji", "cpu"),
        ("Ekonomi", "chart.line.uptrend.xyaxis"),
        ("İK & Organizasyon", "person.3.fill"),
        ("Strateji", "target")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("rt_title".localized())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("rt_subtitle".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.0) { cat in
                            EventCategoryChip(
                                title: cat.0,
                                iconName: cat.1,
                                isSelected: selectedCategory == cat.0
                            ) {
                                selectedCategory = cat.0
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Featured Card
                FeaturedRoundtableCard(
                    title: "Yapay Zeka Çağında Liderlik: Stratejilerimiz Nasıl Değişmeli?",
                    description: "AI dönüşümü, liderlik yetkinliklerini ve organizasyon kültürünü nasıl yeniden şekillendiriyor?",
                    participantCount: 28,
                    imageName: "ai_meeting"
                )
                .padding(.horizontal, 20)
                
                // AI Summary Card
                AISummaryCard()
                    .padding(.horizontal, 20)
                
                // Secondary Tabs
                HStack(spacing: 24) {
                    TabItemSmall(title: "rt_tab_my_discussions".localized(), isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabItemSmall(title: "rt_tab_following".localized(), isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabItemSmall(title: "rt_tab_completed".localized(), isSelected: selectedTab == 2) { selectedTab = 2 }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("rt_sort".localized())
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // List
                VStack(spacing: 12) {
                    NavigationLink(destination: JoinRoundtableView()) {
                        RoundtableRow(
                            title: "Sürdürülebilirlik ve Net Sıfır Hedefleri",
                            status: "rt_status_active".localized(),
                            statusColor: .green,
                            participantCount: 16,
                            commentCount: 42,
                            activityText: String(format: "rt_last_activity".localized(), "2 saat"),
                            imageName: "wind",
                            dateText: nil
                        )
                    }
                    
                    NavigationLink(destination: JoinRoundtableView()) {
                        RoundtableRow(
                            title: "Global Ekonomide 2025 Beklentileri",
                            status: "rt_status_active".localized(),
                            statusColor: .green,
                            participantCount: 23,
                            commentCount: 68,
                            activityText: String(format: "rt_last_activity".localized(), "5 saat"),
                            imageName: "economy",
                            dateText: nil
                        )
                    }
                    
                    NavigationLink(destination: JoinRoundtableView()) {
                        RoundtableRow(
                            title: "CEO'lar için Yetenek Stratejileri",
                            status: "rt_status_upcoming".localized(),
                            statusColor: .orange,
                            participantCount: 15,
                            commentCount: 0,
                            activityText: String(format: "rt_starts_in".localized(), "2 gün"),
                            imageName: "talent",
                            dateText: "20 Mayıs 2025 • 14:00"
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Start New Roundtable Button
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.2))
                            .frame(width: 48, height: 48)
                        Image(systemName: "person.3.fill")
                            .foregroundColor(AppColors.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("rt_start_new_title".localized())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("rt_start_new_desc".localized())
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("rt_start_button".localized())
                            Image(systemName: "plus")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.primary)
                        .cornerRadius(20)
                    }
                }
                .padding(16)
                .background(AppColors.surface.opacity(0.3))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct TabItemSmall: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                
                if isSelected {
                    Rectangle()
                        .fill(AppColors.primary)
                        .frame(height: 2)
                        .cornerRadius(1)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
    }
}

struct RoundtableView_Previews: PreviewProvider {
    static var previews: some View {
        RoundtableView()
    }
}
