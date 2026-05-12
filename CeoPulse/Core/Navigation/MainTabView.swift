import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showCreateSurvey = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    DashboardView()
                }
                .tag(0)
                
                NavigationView {
                    NetworkView()
                }
                .tag(1)
                
                NavigationView {
                    AskOpinionHomeView()
                }
                .tag(2)
                
                NavigationView {
                    AIInsightsView()
                }
                .tag(3)
                
                NavigationView {
                    ProfileView()
                }
                .tag(4)
            }
            .accentColor(AppColors.primaryAccent)
            
            // Custom Tab Bar to match the premium design
            VStack(spacing: 0) {
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack(alignment: .center) {
                    TabItem(icon: "house.fill", label: "nav_home".localized(), isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabItem(icon: "person.2.fill", label: "nav_network".localized(), isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabItem(icon: "bubble.left.and.bubble.right.fill", label: "Ask Opinion", isSelected: selectedTab == 2) { selectedTab = 2 }
                    TabItem(icon: "sparkles", label: "AI Insights", isSelected: selectedTab == 3) { selectedTab = 3 }
                    TabItem(icon: "person.fill", label: "nav_profile".localized(), isSelected: selectedTab == 4) { selectedTab = 4 }
                }
                .padding(.top, 12)
                .padding(.bottom, 32) // Increased for safe area
                .background(AppColors.surface.opacity(0.98))
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct TabItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? AppColors.primaryAccent : AppColors.textSecondary)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
