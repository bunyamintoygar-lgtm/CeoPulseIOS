import SwiftUI
import AVFoundation

struct AIInsightDetailView: View {
    let insight: AIInsight
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    // Seslendirme Özellikleri
    @State private var isSpeaking = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    let tabs = ["Özet", "Bulgular", "Veri Analizi", "Çıkarımlar"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header (Resim) - Artık Scroll İçinde
                    headerSection
                    
                    // Başlık ve Kategori Alanı
                    titleSection
                    
                    // Tab Seçici
                    tabPicker
                    
                    // Sekme İçerikleri
                    Group {
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
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            // Sayfadan çıkınca sesi durdur
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - Speech Logic
    
    private func toggleSpeech() {
        if isSpeaking {
            speechSynthesizer.pauseSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            if speechSynthesizer.isPaused {
                speechSynthesizer.continueSpeaking()
                isSpeaking = true
            } else {
                let textToRead = insight.content.summaryTab.description
                let utterance = AVSpeechUtterance(string: textToRead)
                
                // Sistemdeki en kaliteli Türkçe sesi bulma (Enhanced/Premium öncelikli)
                let voices = AVSpeechSynthesisVoice.speechVoices()
                let highQualityTurkishVoice = voices.first(where: { 
                    $0.language == "tr-TR" && $0.quality == .enhanced 
                }) ?? AVSpeechSynthesisVoice(language: "tr-TR")
                
                utterance.voice = highQualityTurkishVoice
                
                // Yönetici Sunumu Ayarları: Daha oturaklı ve net bir ton
                utterance.rate = 0.50 // Biraz daha sakin ve anlaşılır
                utterance.pitchMultiplier = 0.95 // Hafifçe daha tok bir ses
                utterance.volume = 1.0
                
                speechSynthesizer.speak(utterance)
                isSpeaking = true
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        ZStack(alignment: .topLeading) {
            // Arka Plan Resmi
            AsyncImage(url: URL(string: insight.imageUrl ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1)
            }
            .frame(height: 280)
            .clipped()
            .ignoresSafeArea(.all, edges: .top)
            
            // Geri Butonu
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(.black.opacity(0.4)))
                    .blur(radius: 0)
            }
            .padding(.top, 10) // Safe area zaten ignore edildiği için sadece küçük bir offset
            .padding(.leading, 20)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(insight.category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.indigo)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.indigo.opacity(0.15))
                    .cornerRadius(6)
                
                Spacer()
                
                // DİNLE BUTONU (Premium Dokunuş)
                Button(action: { toggleSpeech() }) {
                    HStack(spacing: 6) {
                        Image(systemName: isSpeaking ? "pause.fill" : "speaker.wave.2.fill")
                        Text(isSpeaking ? "Durdur" : "Dinle")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSpeaking ? Color.red.opacity(0.2) : Color.white.opacity(0.1))
                    .cornerRadius(20)
                }
                
                if insight.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                        Text("PREMIUM")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.leading, 8)
                }
            }
            
            Text(insight.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 5) // Boşluk 0 -> 5 olarak güncellendi
    }
    
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 12) {
                        Text(tabs[index])
                            .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                            .foregroundColor(selectedTab == index ? .white : .gray.opacity(0.7))
                        
                        ZStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 2)
                            
                            if selectedTab == index {
                                Rectangle()
                                    .fill(Color.indigo)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "activeTab", in: tabAnimation)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 20)
    }
    
    @Namespace private var tabAnimation
    
    // MARK: - Tab Views
    
    private var summaryTabView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(insight.content.summaryTab.description)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .lineSpacing(5)
                .padding(.horizontal, 20)
            
            // İstatistik Kartları (Yenilenmiş Tasarım)
            VStack(spacing: 12) {
                ForEach(insight.content.summaryTab.stats, id: \.self) { stat in
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.indigo.opacity(0.1))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(stat.label)
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                Text(stat.value)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.03), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 24)
    }
    
    private var findingsTabView: some View {
        VStack(spacing: 16) {
            ForEach(insight.content.findingsTab) { finding in
                VStack(alignment: .leading, spacing: 8) {
                    Text(finding.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(finding.desc)
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.8))
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white.opacity(0.07))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    private var analysisTabView: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Trend Grafiği
            VStack(alignment: .leading, spacing: 16) {
                Text("Stratejik Trendler")
                    .font(.system(size: 17, weight: .bold))
                
                if let description = insight.content.analysisTab.analysisDescription {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .padding(.bottom, 8)
                }
                
                TrendLineChartView(series: insight.content.analysisTab.trends.map { trend in
                    TrendLineData(label: trend.label, points: trend.points, color: Color(hex: trend.color))
                })
            }
            .padding(.horizontal, 20)
            
            // Bölgesel Dağılım
            VStack(alignment: .leading, spacing: 16) {
                Text("Bölgesel Etki")
                    .font(.system(size: 17, weight: .bold))
                
                ForEach(insight.content.analysisTab.regionalData) { region in
                    HStack(spacing: 12) {
                        Text(region.region)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 80, alignment: .leading)
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            Capsule()
                                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                                .frame(width: (UIScreen.main.bounds.width - 160) * (region.percentage / 100), height: 8)
                        }
                        
                        Text("%\(Int(region.percentage))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 24)
    }
    
    private var recommendationsTabView: some View {
        VStack(spacing: 16) {
            ForEach(insight.content.recommendationsTab) { rec in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(rec.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        
                        // Yerelleştirilmiş Rozet
                        let impactText = rec.impact == "High" ? "Yüksek" : (rec.impact == "Medium" ? "Orta" : rec.impact)
                        
                        Text(impactText)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(rec.impact == "High" ? Color.red.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundColor(rec.impact == "High" ? .red : .orange)
                            .cornerRadius(4)
                    }
                    
                    Text(rec.desc)
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.white.opacity(0.07))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}


