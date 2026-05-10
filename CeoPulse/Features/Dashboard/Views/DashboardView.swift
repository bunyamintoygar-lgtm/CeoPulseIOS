import SwiftUI

struct DashboardView: View {
    @StateObject private var surveyViewModel = SurveyViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("CEOPULSE")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                        .kerning(1.5)
                    
                    Spacer()
                    
                    // Notification Icon with Badge
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .symbolEffect(.pulse, options: .repeating)
                            .foregroundColor(.white)
                        
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 14, height: 14)
                            .overlay(Text("3").font(.system(size: 8, weight: .bold)).foregroundColor(.white))
                            .offset(x: 4, y: -4)
                    }
                    .padding(.trailing, 12)
                    
                    // Premium Badge
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                        Text("premium".localized())
                            .font(.system(size: 10, weight: .black))
                    }
                    .foregroundColor(AppColors.premiumGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.premiumGold.opacity(0.5), lineWidth: 1)
                    )
                }
                
                UserProfileSection()
                
                AIInsightCard()
                
                // Metrics Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        NavigationLink(destination: NetworkView()) {
                            MetricCard(
                                title: "network_activity".localized(),
                                value: "3",
                                description: "new_connection_requests".localized(),
                                iconName: "person.2.fill",
                                iconColor: .blue,
                                actionLabel: "view_network".localized(),
                                showProgress: false,
                                progressValue: nil,
                                showBadge: false,
                                badgeText: nil
                            )
                            .frame(width: 150)
                        }
                        
                        NavigationLink(destination: SurveysHomeView()) {
                            MetricCard(
                                title: "surveys".localized(),
                                value: "\(surveyViewModel.activeSurveysList.count)",
                                description: surveyViewModel.activeSurveysList.count > 0 ? "active_surveys_ready".localized() : "no_active_surveys".localized(),
                                iconName: "chart.pie.fill",
                                iconColor: .green,
                                actionLabel: "vote".localized(),
                                showProgress: surveyViewModel.activeSurveysList.count > 0,
                                progressValue: 0.5, // Placeholder for progress
                                showBadge: surveyViewModel.activeSurveysList.count > 0,
                                badgeText: "new".localized()
                            )
                            .frame(width: 150)
                        }
                        
                        NavigationLink(destination: RoundtableView()) {
                            MetricCard(
                                title: "roundtable".localized(),
                                value: "1",
                                description: "active_discussion".localized(),
                                iconName: "bubble.left.and.bubble.right.fill",
                                iconColor: .orange,
                                actionLabel: "join_discussion".localized(),
                                showProgress: false,
                                progressValue: nil,
                                showBadge: true,
                                badgeText: "ai_summary_ready".localized()
                            )
                            .frame(width: 150)
                        }
                    }
                }
                
                AskOpinionBanner()
                
                // Events Section Header
                HStack {
                    Text("upcoming_events".localized())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("see_all".localized())
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryAccent)
                }
                
                // Sample Event Card
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
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            surveyViewModel.refreshAll()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
