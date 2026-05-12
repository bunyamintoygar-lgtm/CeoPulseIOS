import SwiftUI

struct FeaturedAnalysisCard: View {
    let title: String
    let description: String
    let readTime: Int
    let date: String
    let category: String
    let imageUrl: String?
    
    @State private var isHovered = false // Animasyon kontrolü
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Image or Brain Mesh Background
            Group {
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(isHovered ? 1.05 : 1.0) // Hafif zoom efekti
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                } else {
                    LinearGradient(
                        colors: [Color(hex: "1A1B2E"), Color(hex: "2D2E4A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(height: 240)
            .clipped()
            .cornerRadius(24)
            
            // Bottom Information Panel (Animasyonlu)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Kategori Rozeti
                    Text(category.uppercased())
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(String(format: "ai_read_time".localized(), readTime))
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.black.opacity(0.85)
                    .background(.ultraThinMaterial)
            )
            .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
            .offset(y: isHovered ? 0 : 100) // Başlangıçta aşağıda gizli
            .opacity(isHovered ? 1 : 0) // Başlangıçta şeffaf
        }
        .frame(height: 240)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            // Sayfa açıldığında kısa bir süre sonra ilk kartı otomatik göster (Demo için)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isHovered = true
            }
        }
        // Dokunma/Basılı tutma efekti için
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                // Not: Hover olmayan mobil cihazlarda dokunma ile çalışır
                // Ama kullanıcı zaten tıklayacağı için animasyonun görünmesi istenir.
                // presentation logic'e göre ayarlanabilir.
            }
        }, perform: {})
    }
}



