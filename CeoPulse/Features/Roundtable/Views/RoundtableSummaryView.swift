import SwiftUI

struct RoundtableSummaryView: View {
    let roundtable: Roundtable
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                summaryHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero Section
                        summaryHeroSection
                        
                        // Table Status
                        statusSection
                        
                        // Highlights
                        highlightsSection
                        
                        // Questions
                        questionsSection
                        
                        // Participant Insights
                        insightsSection
                        
                        // Documents
                        documentsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var summaryHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Yuvarlak Masa Özeti")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text("Masa Detayları ve Sonuçlar")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.leading, 12)
            
            Spacer()
            
            Button(action: { }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var summaryHeroSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(roundtable.category)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Tamamlandı")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(roundtable.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                    
                    Text(roundtable.description ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(3)
                }
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .background(
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .blur(radius: 20)
                    )
            }
            
            // Stats Row
            HStack(spacing: 0) {
                StatItem(icon: "calendar", title: roundtable.startTime.formatted(date: .long, time: .omitted), subtitle: "Salı")
                Spacer()
                StatItem(icon: "clock", title: "20:30 - 22:00", subtitle: roundtable.estimatedDuration ?? "90 dakika")
                Spacer()
                StatItem(icon: "person.2", title: "12 Katılımcı", subtitle: "10 uzman, 2 davetli")
            }
            .padding(.top, 10)
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Masa Durumu")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.2), lineWidth: 2)
                        .frame(width: 32, height: 32)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Süresi Geçmiş & Tamamlandı")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                    Text("Bu yuvarlak masa oturumu \(roundtable.startTime.formatted(date: .long, time: .omitted)) tarihinde tamamlandı.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Öne Çıkan Başlıklar")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HighlightCard(icon: "target", title: "Verimlilik Artışı", desc: "Yapay zeka çözümleriyle süreçlerde %20'ye varan verimlilik artışı sağlanabilir.")
                    HighlightCard(icon: "exclamationmark.triangle", title: "Veri Kalitesi", desc: "Doğru veri yönetimi, yapay zeka projelerinin başarısı için kritik önemde.")
                    HighlightCard(icon: "person.3", title: "İnsan & Teknoloji", desc: "Yapay zeka insanın yerini almayacak, onun potansiyelini artıracak.")
                }
            }
        }
    }
    
    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tartışılan Sorular")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 1) {
                QuestionSummaryRow(number: 1, title: "Yapay zeka uygulamalarında şu anki en büyük engeller nelerdir?", comments: 12, likes: 24)
                QuestionSummaryRow(number: 2, title: "Yapay zeka yatırımlarında öncelik verilmesi gereken alanlar hangileri?", comments: 10, likes: 18)
                QuestionSummaryRow(number: 3, title: "İnsan kaynağının yapay zeka dönüşümüne adaptasyonu nasıl sağlanabilir?", comments: 8, likes: 15)
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            
            Button(action: { }) {
                HStack {
                    Spacer()
                    Text("Tüm tartışma sorularını gör")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.purple)
            }
            .padding(.top, 4)
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Katılımcı Görüş Özeti")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 10)
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: 0.86)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("86%")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Olumlu")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genel Değerlendirme")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Katılımcıların büyük çoğunluğu yapay zekanın iş dünyasına katkısının yüksek olacağını düşünüyor. En çok vurgulanan konular veri yönetimi ve yetkinlik gelişimi oldu.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(2)
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.03))
            .cornerRadius(20)
            
            Button(action: { }) {
                HStack {
                    Spacer()
                    Text("Tüm değerlendirmeleri gör")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.purple)
            }
        }
    }
    
    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dökümanlar")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Yuvarlak Masa Notları.pdf")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("PDF • 1.2 MB")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                Button(action: { }) {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
        }
    }
}

// MARK: - Subviews

struct StatItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.4))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

struct HighlightCard: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.purple)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text(desc)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .lineSpacing(2)
        }
        .padding(16)
        .frame(width: 160)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
}

struct QuestionSummaryRow: View {
    let number: Int
    let title: String
    let comments: Int
    let likes: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 24, height: 24)
                    Text("\(number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineSpacing(2)
                    
                    HStack(spacing: 12) {
                        Label("\(comments) yorum", systemImage: "bubble.left")
                        Label("\(likes) beğeni", systemImage: "hand.thumbsup")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
            }
            .padding(16)
            
            Divider().background(Color.white.opacity(0.05))
        }
    }
}
