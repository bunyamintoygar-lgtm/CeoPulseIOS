import SwiftUI

struct SurveysHomeView: View {
    @State private var selectedTab = "Aktif Anketler"
    @State private var searchText = ""
    @State private var showCreateSurvey = false
    
    let tabs = ["Aktif Anketler", "Tamamlananlar", "Taslaklarım", "Arşiv"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Anketler")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Görüşünüz, geleceği şekillendirir.")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            Button(action: {}) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(tabs, id: \.self) { tab in
                                SurveyTabButton(title: tab, isSelected: selectedTab == tab) {
                                    withAnimation {
                                        selectedTab = tab
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            if selectedTab == "Aktif Anketler" {
                                activeSurveysList
                            } else if selectedTab == "Tamamlananlar" {
                                completedSurveysList
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    Button(action: { showCreateSurvey = true }) {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, Color(hex: "6C38FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateSurvey) {
                CreateSurveyView()
            }
        }
    }
    
    private var activeSurveysList: some View {
        VStack(spacing: 20) {
            SurveyCard(
                survey: dummySurvey1,
                totalVotes: 248,
                participationRate: 0.62,
                timeRemaining: "5 gün kaldı",
                isAnonymous: true,
                onJoin: {}
            )
            
            SurveyCard(
                survey: dummySurvey2,
                totalVotes: 156,
                participationRate: 0.48,
                timeRemaining: "3 gün kaldı",
                isAnonymous: false,
                onJoin: {}
            )
            
            // Privacy Note
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "shield.fill")
                        .foregroundColor(.purple)
                }
                
                Text("Anketlerde anonim kalabilir, güvenli bir şekilde görüşlerinizi paylaşabilirsiniz.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Daha Fazla Bilgi")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
        }
    }
    
    private var completedSurveysList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tamamlanan Anketler")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Tümünü Gör") {
                    // Action
                }
                .font(.system(size: 13))
                .foregroundColor(.purple)
            }
            
            SurveyCompletedRow(title: "Hibrit çalışma modellerinin verimliliğe etkisi nedir?", date: "Nisan 2025", rate: 92, icon: "chart.line.uptrend.xyaxis", color: .purple)
            SurveyCompletedRow(title: "2025'te en büyük iş önceliğiniz hangisi?", date: "Mart 2025", rate: 89, icon: "person.2.fill", color: .blue)
            SurveyCompletedRow(title: "Sürdürülebilirlik yatırımlarınızın öncelik alanı nedir?", date: "Şubat 2025", rate: 91, icon: "leaf.fill", color: .green)
        }
    }
}

struct SurveyTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.purple.opacity(0.2) : Color.white.opacity(0.05))
                .foregroundColor(isSelected ? .purple : AppColors.textSecondary)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        }
    }
}

// Dummy Data
let dummySurvey1 = Survey(id: UUID(), creatorId: UUID(), title: "2026 yılında şirketinizin yapay zeka yatırımlarını nasıl planlıyorsunuz?", description: "Küresel CEO Pulse Anketi – Mayıs 2025", categoryId: "artificial-intelligence", coverImageUrl: nil, targetAudience: "public", status: .active, startDate: Date(), endDate: nil, isAnonymous: true, resultVisibility: .immediate, allowEditResponses: false, participationLimit: nil, createdAt: Date())

let dummySurvey2 = Survey(id: UUID(), creatorId: UUID(), title: "Küresel ekonomik belirsizlikler iş stratejilerinizi nasıl etkiliyor?", description: "CEO Pulse Ekonomi Anketi – Mayıs 2025", categoryId: "economy", coverImageUrl: nil, targetAudience: "public", status: .active, startDate: Date(), endDate: nil, isAnonymous: false, resultVisibility: .immediate, allowEditResponses: false, participationLimit: nil, createdAt: Date())
