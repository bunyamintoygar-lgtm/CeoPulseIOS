import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    DashboardView()
                }
                .tag(0)
                
                NetworkView()
                    .tag(1)
                
                AIInsightsView()
                    .tag(2)
                
                Color.black.ignoresSafeArea() // Placeholder for Notifications
                    .tag(3)
                
                ProfileView()
                    .tag(4)
            }
            .accentColor(AppColors.primaryAccent)
            
            // Custom Tab Bar to match the premium design
            VStack(spacing: 0) {
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack {
                    TabItem(icon: "house.fill", label: "nav_home".localized(), isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabItem(icon: "person.2.fill", label: "nav_network".localized(), isSelected: selectedTab == 1) { selectedTab = 1 }
                    
                    // Center Floating Action Button
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primaryAccent)
                                .frame(width: 56, height: 56)
                                .shadow(color: AppColors.primaryAccent.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -20)
                    
                    TabItem(icon: "bell.fill", label: "nav_notifications".localized(), isSelected: selectedTab == 3) { selectedTab = 3 }
                    TabItem(icon: "person.fill", label: "nav_profile".localized(), isSelected: selectedTab == 4) { selectedTab = 4 }
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
                .background(AppColors.surface.opacity(0.95))
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
