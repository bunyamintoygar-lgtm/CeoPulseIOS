import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let description: String
    let iconName: String
    let iconColor: Color
    let actionLabel: String
    let showProgress: Bool
    let progressValue: Double?
    let showBadge: Bool
    let badgeText: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon & Badge Row
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(iconColor)
                }
                
                Spacer()
                
                if showBadge, let badgeText = badgeText {
                    Text(badgeText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.premiumGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.premiumGold.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Value & Title
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if showProgress, let progress = progressValue {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(AppColors.successGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 40, height: 40)
                .padding(.vertical, 4)
            }
            
            Spacer(minLength: 0)
            
            // Action button-like footer
            HStack {
                Text(actionLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.top, 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct MetricCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 12) {
            MetricCard(
                title: "Ağ Aktivitesi",
                value: "3",
                description: "Yeni bağlantı isteği",
                iconName: "person.2.fill",
                iconColor: .purple,
                actionLabel: "Ağı Görüntüle",
                showProgress: false,
                progressValue: nil,
                showBadge: false,
                badgeText: nil
            )
            
            MetricCard(
                title: "Anketler",
                value: "2",
                description: "Bekleyen anket",
                iconName: "chart.pie.fill",
                iconColor: .green,
                actionLabel: "Oy Kullan",
                showProgress: true,
                progressValue: 0.62,
                showBadge: false,
                badgeText: nil
            )
        }
        .padding()
        .background(AppColors.background)
    }
}
