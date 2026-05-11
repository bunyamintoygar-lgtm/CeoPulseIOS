import SwiftUI

struct AIInsightPDFView: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header: Logo & Title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CEOPULSE STRATEJİK ANALİZ")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.gray)
                    Text(insight.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                Spacer()
                // Logo placeholder or text
                Text("AI INSIGHTS")
                    .font(.system(size: 12, weight: .bold))
                    .padding(8)
                    .background(Color.black)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)
            
            Divider()
            
            // Meta Info
            HStack {
                Label(insight.category, systemImage: "tag.fill")
                Spacer()
                Label("\(insight.readTime) dk okuma", systemImage: "clock.fill")
                Spacer()
                Text(Date().formatted(date: .long, time: .omitted))
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.gray)
            
            // 1. YÖNETİCİ ÖZETİ
            VStack(alignment: .leading, spacing: 12) {
                Text("1. YÖNETİCİ ÖZETİ")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.indigo)
                
                Text(insight.content.summaryTab.description)
                    .font(.system(size: 12))
                    .lineSpacing(4)
                    .multilineTextAlignment(.justified)
            }
            
            // 2. KRİTİK BULGULAR
            VStack(alignment: .leading, spacing: 12) {
                Text("2. KRİTİK BULGULAR")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.indigo)
                
                ForEach(insight.content.findingsTab) { finding in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• \(finding.title)")
                            .font(.system(size: 12, weight: .bold))
                        Text(finding.desc)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                    }
                }
            }
            
            // 3. STRATEJİK ÇIKARIMLAR VE ÖNERİLER
            VStack(alignment: .leading, spacing: 12) {
                Text("3. STRATEJİK ÖNERİLER")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.indigo)
                
                ForEach(insight.content.recommendationsTab) { rec in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("» \(rec.title)")
                            .font(.system(size: 12, weight: .bold))
                        Text(rec.desc)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                    }
                }
            }
            
            Spacer()
            
            // Footer
            Divider()
            Text("Bu rapor CeoPulse AI tarafından üretilmiştir. Gizli ve isme özeldir.")
                .font(.system(size: 8))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(40)
        .frame(width: 595) // A4 width in points approx
        .background(Color.white)
    }
}
