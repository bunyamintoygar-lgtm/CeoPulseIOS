import SwiftUI

struct AIInsightDetailView: View {
    let insight: AIInsight
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    let tabs = ["Özet", "Bulgular", "Veri Analizi", "Çıkarımlar"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Resim ve Başlık)
                headerSection
                
                // Tab Seçici
                tabPicker
                
                // İçerik
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if selectedTab == 0 {
                            summaryTabView
                        } else if selectedTab == 1 {
                            findingsTabView
                        } else if selectedTab == 2 {
                            analysisTabView
                        } else {
                            recommendationsTabView
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Arka Plan Resmi
            AsyncImage(url: URL(string: insight.imageUrl ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 250)
            .clipped()
            .overlay(
                LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.category.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.indigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.indigo.opacity(0.2))
                    .cornerRadius(4)
                
                Text(insight.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(20)
            
            // Geri Butonu
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(.black.opacity(0.5)))
            }
            .padding(.top, 50)
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tabs[index])
                            .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.indigo : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 16)
        .background(Color.black)
    }
    
    // MARK: - Tab Views
    
    private var summaryTabView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(insight.content.summaryTab.description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineSpacing(6)
                .padding(.horizontal, 20)
            
            // İstatistik Kartları
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(insight.content.summaryTab.stats, id: \.self) { stat in
                    VStack(spacing: 8) {
                        Image(systemName: stat.icon)
                            .foregroundColor(.indigo)
                        Text(stat.value)
                            .font(.system(size: 18, weight: .bold))
                        Text(stat.label)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var findingsTabView: some View {
        VStack(spacing: 16) {
            ForEach(insight.content.findingsTab) { finding in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: finding.percentage / 100)
                            .stroke(Color.indigo, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        Text("%\(Int(finding.percentage))")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(width: 44, height: 44)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(finding.title)
                            .font(.system(size: 16, weight: .bold))
                        Text(finding.desc)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: finding.icon)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var analysisTabView: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Trend Grafiği
            VStack(alignment: .leading, spacing: 16) {
                Text("Stratejik Trendler")
                    .font(.system(size: 18, weight: .bold))
                
                TrendLineChartView(series: insight.content.analysisTab.trends.map { trend in
                    TrendLineData(label: trend.label, points: trend.points, color: Color(hex: trend.color))
                })
            }
            .padding(.horizontal, 20)
            
            // Bölgesel Dağılım
            VStack(alignment: .leading, spacing: 16) {
                Text("Bölgesel Etki")
                    .font(.system(size: 18, weight: .bold))
                
                ForEach(insight.content.analysisTab.regionalData) { region in
                    HStack {
                        Text(region.region)
                            .font(.system(size: 14))
                        Spacer()
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            Rectangle()
                                .fill(Color.indigo)
                                .frame(width: 150 * (region.percentage / 100), height: 8)
                        }
                        .frame(width: 150)
                        .cornerRadius(4)
                        
                        Text("%\(Int(region.percentage))")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 40)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var recommendationsTabView: some View {
        VStack(spacing: 16) {
            ForEach(insight.content.recommendationsTab) { rec in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: rec.icon)
                            .foregroundColor(.indigo)
                        Text(rec.title)
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(rec.impact)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(rec.impact == "High" ? Color.red.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundColor(rec.impact == "High" ? .red : .orange)
                            .cornerRadius(4)
                    }
                    
                    Text(rec.desc)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 20)
    }
}

// Renk Helper'ı
extension Color {
    }
}
