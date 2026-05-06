import SwiftUI

struct CompletedSurveyRow: View {
    let title: String
    let date: String
    let rate: Int
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(date)
                    Text("•")
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("survey_completed_status".localized())
                    }
                    .foregroundColor(.green)
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("%\(rate)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
                Text("survey_participation_rate".localized())
                    .font(.system(size: 8))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .background(AppColors.surface.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
