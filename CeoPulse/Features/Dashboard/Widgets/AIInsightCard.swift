import SwiftUI

struct AIInsightCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                Text("ai_insight_title".localized())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Content
            HStack(alignment: .center) {
                Text("ai_insight_desc".localized())
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)
                
                Spacer()
                
                // Simplified Line Graph using Path
                LineGraph()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 80, height: 40)
            }
            
            // Action Button
            NavigationLink(destination: AIInsightsView()) {
                HStack {
                    Text("detailed_insights".localized())
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.12))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .padding(20)
        .background(
            AppColors.aiCardGradient
                .overlay(
                    // Subtle glass effect
                    Color.white.opacity(0.05)
                )
        )
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct LineGraph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.8))
        path.addLine(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.2))
        return path
    }
}

struct AIInsightCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            AIInsightCard()
                .padding()
        }
    }
}
