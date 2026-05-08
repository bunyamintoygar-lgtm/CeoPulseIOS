import SwiftUI

struct SurveyCard: View {
    let survey: Survey
    let totalVotes: Int
    let participationRate: Double // 0.0 to 1.0
    let timeRemaining: String
    let isAnonymous: Bool
    let buttonTitle: String
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Top Row: Badges and Timer
            HStack {
                HStack(spacing: 6) {
                    Text(survey.status.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.purple.opacity(0.15)))
                        .foregroundColor(.purple)
                    
                    if isAnonymous {
                        HStack(spacing: 4) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 10))
                                .symbolRenderingMode(.hierarchical)
                            Text("Anonim")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                        .foregroundColor(AppColors.textSecondary)
                    }
                    
                    if let category = ConfigManager.shared.surveyCategories.first(where: { $0.id == survey.categoryId }) {
                        HStack(spacing: 4) {
                            if let icon = category.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 10))
                                    .symbolRenderingMode(.hierarchical)
                            }
                            Text(category.name)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(LinearGradient(colors: [.purple.opacity(0.1), .blue.opacity(0.1)], startPoint: .leading, endPoint: .trailing)))
                        .foregroundColor(.purple)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .symbolRenderingMode(.hierarchical)
                        .symbolEffect(.pulse, options: .repeating)
                    Text(timeRemaining)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            }
            
            // Middle Content: Title and Progress
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(survey.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    Text(survey.description ?? "Küresel CEO Pulse Anketi")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Participation Rate Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 5)
                        .frame(width: 75, height: 75)
                    
                    Circle()
                        .trim(from: 0, to: participationRate)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, Color(hex: "6C38FF"), .blue],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 75, height: 75)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: .purple.opacity(0.3), radius: 4)
                    
                    VStack(spacing: 0) {
                        Text("%\(Int(participationRate * 100))")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                        Text("Katılım")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Bottom Row: Avatars and Button
            HStack {
                HStack(spacing: -10) {
                    ForEach(0..<min(totalVotes, 4), id: \.self) { i in
                        Image("ceo_profile_\(i + 1)")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                    }
                    
                    if totalVotes > 4 {
                        Text("+\(totalVotes - 4)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.purple.opacity(0.4)))
                            .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                    }
                }
                
                Spacer(minLength: 12)
                
                Button(action: onJoin) {
                    Text(buttonTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [Color(hex: "6C38FF"), .purple], startPoint: .leading, endPoint: .trailing))
                                .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
                        )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(colors: [.white.opacity(0.1), .clear, .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
    }
}


struct SurveyCompletedRow: View {
    let title: String
    let date: String
    let rate: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(date)
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .green)
                            .symbolEffect(.bounce, value: true)
                        Text("Tamamlandı")
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
                Text("Katılım Oranı")
                    .font(.system(size: 8))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(Color.white.opacity(0.02))
        .cornerRadius(16)
    }
}
