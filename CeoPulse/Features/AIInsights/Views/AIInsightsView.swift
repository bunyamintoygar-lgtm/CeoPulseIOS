import SwiftUI

struct AIInsightsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AIInsightsViewModel()
    
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
                                isSelected: viewModel.selectedCategory == cat.0
                            ) {
                                viewModel.selectedCategory = cat.0
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Featured
                if let featured = viewModel.featuredInsight {
                    NavigationLink(destination: AIInsightDetailView(insight: featured)) {
                        FeaturedAnalysisCard(
                            title: featured.title,
                            description: featured.subtitle ?? "",
                            readTime: featured.readTime,
                            date: "Bugün",
                            imageUrl: featured.imageUrl
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
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
                            ForEach(viewModel.filteredInsights.prefix(3)) { insight in
                                NavigationLink(destination: AIInsightDetailView(insight: insight)) {
                                    TrendAnalysisCard(
                                        title: insight.title,
                                        description: insight.subtitle ?? "",
                                        chartType: .line, // Default to line for AI
                                        date: "Yeni",
                                        readTime: insight.readTime,
                                        iconName: "cpu",
                                        iconColor: .purple,
                                        imageUrl: insight.imageUrl,
                                        isPremium: insight.isPremium
                                    )
                                }
                            }
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
                        ForEach(viewModel.filteredInsights.dropFirst(3)) { insight in
                            NavigationLink(destination: AIInsightDetailView(insight: insight)) {
                                RecommendationRow(
                                    title: insight.title,
                                    description: insight.subtitle ?? "",
                                    category: insight.category,
                                    date: "Bugün",
                                    readTime: insight.readTime,
                                    imageUrl: insight.imageUrl
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchInsights()
            }
        }
    }
}

struct RecommendationRow: View {
    let title: String
    let description: String
    let category: String
    let date: String
    let readTime: Int
    let imageUrl: String?
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            AsyncImage(url: URL(string: imageUrl ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(Image(systemName: "photo").foregroundColor(.white.opacity(0.2)))
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            .clipped()
            
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
