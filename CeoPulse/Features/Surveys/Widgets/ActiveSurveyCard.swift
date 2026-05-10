import SwiftUI

struct ActiveSurveyCard: View {
    let title: String
    let subtitle: String
    let daysLeft: Int
    let participationRate: Double
    let voterCount: Int
    let isAnonymous: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Badges and Timer
            HStack {
                HStack(spacing: 8) {
                    Text("rt_status_active".localized())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(6)
                    
                    if isAnonymous {
                        HStack(spacing: 4) {
                            Image(systemName: "eye.slash.fill")
                            Text("survey_anonymous".localized())
                        }
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(String(format: "survey_days_left".localized(), daysLeft))
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            }
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 5)
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .trim(from: 0, to: participationRate)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("%\(Int(participationRate * 100))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("survey_participation_rate".localized())
                            .font(.system(size: 7))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .frame(width: 45)
                    }
                }
            }
            
            // Avatars and Voter Count
            HStack(spacing: 12) {
                HStack(spacing: -8) {
                    ForEach(0..<4) { _ in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 24, height: 24)
                            .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 1))
                    }
                    Text("+\(voterCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Text(String(format: "survey_total_voted".localized(), voterCount))
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Action Button
            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("survey_join_button".localized())
                    Image(systemName: "chevron.right")
                    Spacer()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(AppColors.surface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
