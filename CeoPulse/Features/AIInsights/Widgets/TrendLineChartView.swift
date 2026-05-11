import SwiftUI

struct TrendLineData: Identifiable {
    let id = UUID()
    let label: String
    let points: [Double]
    let color: Color
}

struct TrendLineChartView: View {
    let series: [TrendLineData]
    let gridCount: Int = 5
    
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Grafik Alanı
            ZStack {
                // Arka Plan Izgarası
                VStack {
                    ForEach(0..<gridCount, id: \.self) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 1)
                        if i < gridCount - 1 { Spacer() }
                    }
                }
                
                // Çizgiler (Her seriyi kendi max değerine göre normalize ederek çiziyoruz)
                ForEach(series) { item in
                    let seriesMax = item.points.max() ?? 1.0
                    let normalizedMax = seriesMax == 0 ? 1.0 : seriesMax * 1.1
                    
                    LineShape(points: item.points, maxValue: normalizedMax)
                        .trim(from: 0, to: animationProgress)
                        .stroke(
                            LinearGradient(colors: [item.color, item.color.opacity(0.6)], startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: item.color.opacity(0.4), radius: 6, x: 0, y: 4)
                }
            }
            .frame(height: 220)
            
            // Legend (Açıklama)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(series) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 8, height: 8)
                            Text(item.label)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }
}

// Çizgi Şekli
struct LineShape: Shape {
    let points: [Double]
    let maxValue: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(points.count - 1)
        
        for (index, point) in points.enumerated() {
            let x = CGFloat(index) * stepX
            let y = rect.height - (CGFloat(point / maxValue) * rect.height)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// Preview
struct TrendLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            TrendLineChartView(series: [
                TrendLineData(label: "YZ Adaptasyonu", points: [10, 25, 45, 58, 70, 85], color: .indigo),
                TrendLineData(label: "Verimlilik", points: [40, 42, 45, 50, 65, 80], color: .green),
                TrendLineData(label: "Risk", points: [60, 55, 45, 30, 25, 15], color: .red)
            ])
            .padding()
        }
    }
}
