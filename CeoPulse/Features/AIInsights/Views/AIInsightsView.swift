import SwiftUI

struct AIInsightsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory = "Tümü"
    
    let categories = [
        ("Tümü", "square.grid.2x2.fill"),
        ("Teknoloji", "cpu"),
        ("Ekonomi", "chart.line.uptrend.xyaxis"),
        ("İK & Yetenek", "person.3.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ai_insights_title".localized())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("ai_insights_subtitle".localized())
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                        Text("PREMIUM")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Categories
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
                
                // Featured
                FeaturedAnalysisCard(
                    title: "2026'da CEO'ların önceliği: Yapay Zeka ve Yetenek Yönetimi",
                    description: "Küresel CEO Pulse verilerine göre 2026'da yatırım öncelikleri değişiyor.",
                    readTime: 5,
                    date: "18 May 2025"
                )
                .padding(.horizontal, 20)
                
                // Trend Analyses Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("ai_trend_analyses".localized())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("see_all".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TrendAnalysisCard(
                                title: "Yapay Zeka Yatırımları",
                                description: "CEO'ların %68'i 2026'da AI yatırımlarını artırmayı planlıyor.",
                                chartType: .line,
                                date: "18 May 2025",
                                readTime: 4,
                                iconName: "cpu",
                                iconColor: .purple,
                                isPremium: true
                            )
                            
                            TrendAnalysisCard(
                                title: "Küresel Ekonomik Görünüm",
                                description: "Büyüme beklentileri zayıflarken, riskler artıyor.",
                                chartType: .bar,
                                date: "17 May 2025",
                                readTime: 6,
                                iconName: "globe",
                                iconColor: .green,
                                isPremium: false
                            )
                            
                            TrendAnalysisCard(
                                title: "Yetenek Yönetimi",
                                description: "En büyük zorluk: Yetenek elde tutma ve geliştirme.",
                                chartType: .circular(progress: 0.74),
                                date: "16 May 2025",
                                readTime: 3,
                                iconName: "person.3.fill",
                                iconColor: .orange,
                                isPremium: true
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Recommended Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("ai_recommended_for_you".localized())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        RecommendationRow(
                            title: "Dijital Dönüşümde Yeni Dalga",
                            description: "Şirketlerin %61'i dijital dönüşüm süreçlerini hızlandırırken...",
                            category: "ai_category_tech".localized(),
                            date: "15 May 2025",
                            readTime: 4
                        )
                        
                        RecommendationRow(
                            title: "Faiz, Enflasyon ve Piyasalar",
                            description: "Küresel piyasaları etkileyen makro gelişmeler ve CEO'lar için etkileri.",
                            category: "ai_category_economy".localized(),
                            date: "14 May 2025",
                            readTime: 4
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct RecommendationRow: View {
    let title: String
    let description: String
    let category: String
    let date: String
    let readTime: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Image Placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(Image(systemName: "photo").foregroundColor(.white.opacity(0.2)))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(4)
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Text(date)
                    Text("•")
                    Text(String(format: "ai_read_time".localized(), readTime))
                }
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(12)
        .background(AppColors.surface.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct AIInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        AIInsightsView()
    }
}
