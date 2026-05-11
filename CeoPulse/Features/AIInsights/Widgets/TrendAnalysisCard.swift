import SwiftUI

enum TrendChartType {
    case line
    case bar
    case circular(progress: Double)
}

struct TrendAnalysisCard: View {
    let title: String
    let description: String
    let chartType: TrendChartType
    let date: String
    let readTime: Int
    let iconName: String
    let iconColor: Color
    let imageUrl: String? // Added imageUrl support
    let isPremium: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .bold)) // 14 -> 13
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(description)
                .font(.system(size: 10)) // 11 -> 10
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)
                .frame(height: 30, alignment: .top)
            
            // Chart Area - Now just a clean Cover Image
            ZStack {
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.white.opacity(0.05)
                    }
                    .frame(height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(0.7) // Higher opacity for a cleaner look
                }
            }
            .frame(height: 60)
            .padding(.vertical, 8)
            
            HStack {
                Text(date)
                Spacer()
                Text(String(format: "ai_read_time".localized(), readTime))
            }
            .font(.system(size: 10))
            .foregroundColor(AppColors.textSecondary)
        }
        .padding(16)
        .frame(width: 160)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

// Simple shapes for charts
struct LineChartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / 5
        path.move(to: CGPoint(x: 0, y: rect.height * 0.8))
        path.addLine(to: CGPoint(x: step, y: rect.height * 0.6))
        path.addLine(to: CGPoint(x: step * 2, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: step * 3, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: step * 4, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.2))
        return path
    }
}

struct BarChartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let barWidth = rect.width / 9
        let heights: [CGFloat] = [0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.8]
        
        for (i, h) in heights.enumerated() {
            let x = CGFloat(i) * (barWidth + 4)
            let barHeight = rect.height * h
            path.addRoundedRect(
                in: CGRect(x: x, y: rect.height - barHeight, width: barWidth, height: barHeight),
                cornerSize: CGSize(width: 2, height: 2)
            )
        }
        return path
    }
}
