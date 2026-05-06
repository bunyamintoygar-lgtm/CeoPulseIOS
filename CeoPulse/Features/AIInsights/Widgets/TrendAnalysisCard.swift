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
    let isPremium: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                if isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                        Text("PREMIUM")
                    }
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)
                .frame(height: 32, alignment: .top)
            
            // Chart Area
            ZStack {
                switch chartType {
                case .line:
                    LineChartShape()
                        .stroke(
                            LinearGradient(colors: [iconColor, iconColor.opacity(0.2)], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 2
                        )
                case .bar:
                    BarChartShape()
                        .fill(
                            LinearGradient(colors: [iconColor, iconColor.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        )
                case .circular(let progress):
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(colors: [iconColor, iconColor.opacity(0.5)], startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        Text("%\(Int(progress * 100))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(10)
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
