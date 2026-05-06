import SwiftUI

struct NetworkView: View {
    @State private var selectedTab = 0
    
    let tabs = [
        ("net_tab_overview".localized(), 0),
        ("net_tab_my_network".localized(), 0),
        ("net_tab_incoming".localized(), 3),
        ("net_tab_sent".localized(), 0)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("net_title".localized())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("net_subtitle".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                        Image(systemName: "slider.horizontal.3")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Top Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            NetworkTabItem(
                                title: tabs[index].0,
                                badge: tabs[index].1,
                                isSelected: selectedTab == index,
                                action: { selectedTab = index }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Stats Row
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        NetworkStatCard(
                            title: "net_stat_total".localized(),
                            value: "254",
                            description: "\("net_this_month".localized()) +18 ↗",
                            iconName: "person.2.fill",
                            iconColor: .purple
                        )
                        
                        NetworkStatCard(
                            title: "net_stat_new".localized(),
                            value: "37",
                            description: "net_last_30_days".localized(),
                            iconName: "person.badge.plus",
                            iconColor: .blue
                        )
                    }
                    
                    HStack(spacing: 12) {
                        NetworkStatCard(
                            title: "net_stat_requests".localized(),
                            value: "12",
                            description: "net_waiting_for_you".localized(),
                            iconName: "message.fill",
                            iconColor: .orange
                        )
                        
                        NetworkStatCard(
                            title: "net_stat_views".localized(),
                            value: "98",
                            description: "net_last_30_days".localized(),
                            iconName: "eye.fill",
                            iconColor: .green
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Ask Opinion Banner
                AskOpinionBanner()
                    .padding(.horizontal, 20)
                
                // Connection Requests Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("net_requests_title".localized())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("see_all".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ConnectionRequestRow(
                            name: "Murat Korkmaz",
                            title: "CEO",
                            company: "Korkmaz Holding",
                            mutualCount: 12,
                            imageName: "p1"
                        )
                        
                        ConnectionRequestRow(
                            name: "Selin Yılmaz",
                            title: "Genel Müdür",
                            company: "Zirve Teknoloji",
                            mutualCount: 8,
                            imageName: "p2"
                        )
                        
                        ConnectionRequestRow(
                            name: "Ahmet Demir",
                            title: "CEO",
                            company: "Demir Enerji",
                            mutualCount: 5,
                            imageName: "p3"
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Featured Connections Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("net_featured_title".localized())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("see_all".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FeaturedConnectionCard(name: "Burak Arslan", title: "CEO", company: "Arslan Group", imageName: "p4", isOnline: true)
                            FeaturedConnectionCard(name: "Elif Kaya", title: "COO", company: "Kaya Holding", imageName: "p5", isOnline: true)
                            FeaturedConnectionCard(name: "Emre Özcan", title: "CTO", company: "Özcan Teknoloji", imageName: "p6", isOnline: true)
                            FeaturedConnectionCard(name: "Didem Şahin", title: "CHRO", company: "Şahin Group", imageName: "p7", isOnline: true)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Recent Interactions Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("net_recent_interactions".localized())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("see_all".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 44, height: 44)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Kerem Aydın")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Sizin görüş isteğinize yanıt verdi.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                            Text("2 saat önce")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .padding(16)
                    .background(AppColors.surface.opacity(0.5))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct NetworkTabItem: View {
    let title: String
    let badge: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSelected {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 14))
                } else {
                    Image(systemName: "person.2")
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(y: -8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.primary : Color.white.opacity(0.05))
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .cornerRadius(12)
        }
    }
}

struct NetworkView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkView()
    }
}
