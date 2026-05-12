import SwiftUI

struct FeaturedAnalysisCard: View {
    let title: String
    let description: String
    let readTime: Int
    let date: String
    let category: String
    let imageUrl: String?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Image or Brain Mesh Background
            Group {
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                } else {
                    LinearGradient(
                        colors: [Color(hex: "1A1B2E"), Color(hex: "2D2E4A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 100))
                            .foregroundColor(.white.opacity(0.1))
                    )
                }
            }
            .frame(height: 240)
            .clipped()
            .cornerRadius(24)
            
            // Bottom Information Panel (Protects text from image content)
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
                    .font(.system(size: 15, weight: .bold)) // 16 -> 15
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading) // Sola yasla
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading) // Sola yasla
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.black.opacity(0.85)
                    .background(.ultraThinMaterial)
            )
            .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
        }
        .frame(height: 240)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}



