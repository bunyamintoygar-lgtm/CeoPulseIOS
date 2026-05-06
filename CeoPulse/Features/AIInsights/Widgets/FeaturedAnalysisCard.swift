import SwiftUI

struct FeaturedAnalysisCard: View {
    let title: String
    let description: String
    let readTime: Int
    let date: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background with Gradient and AI Brain Mesh
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1A1B2E"), Color(hex: "2D2E4A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // AI Brain mesh placeholder (Simplified with icons)
            HStack {
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 140))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primaryAccent.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(x: 20)
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("ai_featured_analysis".localized())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .frame(maxWidth: 220, alignment: .leading)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .frame(maxWidth: 220, alignment: .leading)
                
                HStack {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Text("ai_read_analysis".localized())
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.indigo)
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Label(String(format: "ai_read_time".localized(), readTime), systemImage: "clock")
                        Text(date)
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(24)
        }
        .frame(height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

