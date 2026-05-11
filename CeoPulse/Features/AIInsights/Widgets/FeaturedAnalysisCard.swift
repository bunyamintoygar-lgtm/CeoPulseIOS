import SwiftUI

struct FeaturedAnalysisCard: View {
    let title: String
    let description: String
    let readTime: Int
    let date: String
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("ai_featured_analysis".localized().uppercased())
                            .font(.system(size: 10, weight: .black))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
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
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("ai_read_analysis".localized())
                            .font(.system(size: 12, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.indigo)
                }
            }
            .padding(16)
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

    }
}

