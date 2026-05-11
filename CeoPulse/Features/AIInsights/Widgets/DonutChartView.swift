import SwiftUI

struct DonutChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

struct DonutChartView: View {
    let data: [DonutChartData]
    let centerLabel: String
    let centerValue: String
    
    @State private var animatedValues: [Double] = []
    
    private var totalValue: Double {
        data.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        ZStack {
            // Halka Dilimleri
            ForEach(0..<data.count, id: \.self) { index in
                Circle()
                    .trim(from: startAngle(for: index), to: endAngle(for: index))
                    .stroke(data[index].color, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.1), value: animatedValues)
            }
            
            // Merkez Metin
            VStack(spacing: 2) {
                Text(centerValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(centerLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 200)
        .onAppear {
            animatedValues = data.map { $0.value }
        }
    }
    
    private func startAngle(for index: Int) -> CGFloat {
        let sum = data.prefix(index).reduce(0) { $0 + $1.value }
        return CGFloat(sum / (totalValue == 0 ? 1 : totalValue))
    }
    
    private func endAngle(for index: Int) -> CGFloat {
        let sum = data.prefix(index + 1).reduce(0) { $0 + $1.value }
        return CGFloat(sum / (totalValue == 0 ? 1 : totalValue))
    }
}

// Preview için örnek veri
struct DonutChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DonutChartView(
                data: [
                    DonutChartData(label: "AI", value: 58, color: .indigo),
                    DonutChartData(label: "ESG", value: 22, color: .green),
                    DonutChartData(label: "Diğer", value: 20, color: .gray.opacity(0.3))
                ],
                centerLabel: "Katılım Oranı",
                centerValue: "%84"
            )
            .padding(40)
        }
    }
}
