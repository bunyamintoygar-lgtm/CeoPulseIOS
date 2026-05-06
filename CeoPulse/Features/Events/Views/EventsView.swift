import SwiftUI

struct EventsView: View {
    @State private var selectedTab = 0
    @State private var selectedCategory = "Tümü"
    
    let categories = [
        ("Tümü", "square.grid.2x2.fill"),
        ("Zirveler", "mountain.2.fill"),
        ("Akşam Yemekleri", "fork.knife"),
        ("Networking", "person.2.fill"),
        ("Webinar", "video.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("events_title".localized())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("events_subtitle".localized())
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
                
                // Main Tabs
                HStack(spacing: 12) {
                    TabButton(title: "events_tab_upcoming".localized(), isSelected: selectedTab == 0, badge: 5) { selectedTab = 0 }
                    TabButton(title: "events_tab_my_events".localized(), isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabButton(title: "events_tab_past".localized(), isSelected: selectedTab == 2) { selectedTab = 2 }
                }
                .padding(.horizontal, 20)
                
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
                
                // Section Header
                HStack {
                    Text("events_tab_upcoming".localized())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Text("events_add_to_calendar".localized())
                            Image(systemName: "calendar.badge.plus")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, 20)
                
                // Event List
                VStack(spacing: 16) {
                    EventCard(
                        title: "Liderler Zirvesi 2025",
                        category: "Zirve",
                        date: "24 Mayıs 2025",
                        time: "09:00 - 17:30",
                        location: "Raffles Hotel, İstanbul",
                        description: "Türkiye ve dünyadan liderlerle bir araya gelerek geleceği konuşuyoruz.",
                        imageName: "bridge",
                        participantCount: 124,
                        actionLabel: "events_see_details".localized(),
                        isBookmarked: false,
                        categoryColor: .purple
                    )
                    
                    EventCard(
                        title: "CEO Dinner – İstanbul",
                        category: "Akşam Yemeği",
                        date: "10 Haziran 2025",
                        time: "19:00 - 22:00",
                        location: "The Bodrum Edition, İstanbul",
                        description: "Seçkin CEO'lar ile samimi bir akşam yemeği ve networking fırsatı.",
                        imageName: "dinner",
                        participantCount: 18,
                        actionLabel: "events_i_will_join".localized(),
                        isBookmarked: true,
                        categoryColor: .orange
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Space for TabBar
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    var badge: Int? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                if let badge = badge {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .padding(4)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.primary : AppColors.surface)
            .foregroundColor(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(isSelected ? 0 : 0.05), lineWidth: 1)
            )
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
