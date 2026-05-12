import SwiftUI

struct FeaturedAnalysisCard: View {
    let title: String
    let description: String
    let readTime: Int
    let date: String
    let category: String
    let imageUrl: String?
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background Gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [Color(hex: "0F0F23"), Color(hex: "1A1B3D")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            HStack(spacing: 0) {
                // Left Content (approx 60% width)
                VStack(alignment: .leading, spacing: 12) {
                    // Category Badge
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 8))
                        Text(category.uppercased())
                            .font(.system(size: 9, weight: .black))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(description)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer(minLength: 16)
                    
                    // Read Button
                    HStack(spacing: 6) {
                        Text("Analizi Oku")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.indigo.opacity(0.3))
                    .cornerRadius(12)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right Image (approx 40% width)
                ZStack(alignment: .bottomTrailing) {
                    if let urlString = imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.white.opacity(0.05)
                        }
                        .frame(width: 140, height: 180)
                        .mask(
                            LinearGradient(
                                colors: [.black, .black, .clear],
                                startPoint: .trailing,
                                endPoint: .leading
                            )
                        )
                    }
                    
                    // Metadata Capsule (Bottom Right)
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("\(readTime) dk")
                        }
                        
                        Divider()
                            .frame(height: 10)
                            .background(Color.white.opacity(0.3))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text("18 May 2025") // Placeholder or actual date logic
                        }
                    }
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(10)
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .frame(height: 220) // Slightly shorter but wider feel
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}



