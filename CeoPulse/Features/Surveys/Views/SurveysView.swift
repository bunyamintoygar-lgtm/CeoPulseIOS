import SwiftUI

struct SurveysView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    let tabs = [
        ("survey_tab_active".localized(), 2),
        ("survey_tab_completed".localized(), 0),
        ("survey_tab_drafts".localized(), 0),
        ("survey_tab_archive".localized(), 0)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("survey_title".localized())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("survey_subtitle".localized())
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
                
                // Top Tabs with Badges
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            SurveyTabItem(
                                title: tabs[index].0,
                                badge: tabs[index].1,
                                isSelected: selectedTab == index,
                                action: { selectedTab = index }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Active Surveys Section
                VStack(spacing: 16) {
                    ActiveSurveyCard(
                        title: "2026 yılında şirketinizin yapay zeka yatırımlarını nasıl planlıyorsunuz?",
                        subtitle: "Küresel CEO Pulse Anketi - Mayıs 2025",
                        daysLeft: 5,
                        participationRate: 0.62,
                        voterCount: 248,
                        isAnonymous: true
                    )
                    
                    ActiveSurveyCard(
                        title: "Küresel ekonomik belirsizlikler iş stratejilerinizi nasıl etkiliyor?",
                        subtitle: "CEO Pulse Ekonomi Anketi - Mayıs 2025",
                        daysLeft: 3,
                        participationRate: 0.48,
                        voterCount: 156,
                        isAnonymous: true
                    )
                }
                .padding(.horizontal, 20)
                
                // Completed Surveys Header
                HStack {
                    Text("survey_completed_title".localized())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("see_all".localized())
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryAccent)
                }
                .padding(.horizontal, 20)
                
                // Completed List
                VStack(spacing: 12) {
                    CompletedSurveyRow(
                        title: "Hibrit çalışma modellerinin verimliliğe etkisi nedir?",
                        date: "Nisan 2025",
                        rate: 92,
                        iconName: "chart.line.uptrend.xyaxis",
                        iconColor: .purple
                    )
                    
                    CompletedSurveyRow(
                        title: "2025’te en büyük iş önceliğiniz hangisi?",
                        date: "Mart 2025",
                        rate: 89,
                        iconName: "person.2.fill",
                        iconColor: .blue
                    )
                    
                    CompletedSurveyRow(
                        title: "Sürdürülebilirlik yatırımlarınızın öncelik alanı nedir?",
                        date: "Şubat 2025",
                        rate: 91,
                        iconName: "leaf.fill",
                        iconColor: .green
                    )
                }
                .padding(.horizontal, 20)
                
                // Privacy Info Banner
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.indigo.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(.indigo)
                    }
                    
                    Text("survey_privacy_info".localized())
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("survey_more_info".localized())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(16)
                .background(AppColors.surface.opacity(0.3))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct SurveyTabItem: View {
    let title: String
    let badge: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSelected {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(isSelected ? Color.white.opacity(0.2) : Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.indigo : Color.white.opacity(0.05))
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct SurveysView_Previews: PreviewProvider {
    static var previews: some View {
        SurveysView()
    }
}
