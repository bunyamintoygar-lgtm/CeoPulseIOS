import SwiftUI

struct SurveyCard: View {
    let survey: Survey
    let totalVotes: Int
    let participationRate: Double // 0.0 to 1.0
    let timeRemaining: String
    let isAnonymous: Bool
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Row: Badges and Timer
            HStack {
                HStack(spacing: 4) {
                    Text(survey.status.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                    
                    if isAnonymous {
                        HStack(spacing: 4) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 10))
                                .symbolRenderingMode(.hierarchical)
                            Text("Anonim")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(AppColors.textSecondary)
                        .cornerRadius(4)
                    }
                    
                    if let category = ConfigManager.shared.surveyCategories.first(where: { $0.id == survey.categoryId }) {
                        HStack(spacing: 4) {
                            if let icon = category.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 10))
                                    .symbolRenderingMode(.hierarchical)
                            }
                            Text(category.name)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .symbolEffect(.pulse, options: .repeating)
                    Text(timeRemaining)
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            }
            
            // Middle Content: Title, Description and Progress
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(survey.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    Text(survey.description ?? "Küresel CEO Pulse Anketi")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Participation Rate Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 4)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: participationRate)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, Color(hex: "6C38FF")],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("%\(Int(participationRate * 100))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Katılım")
                            .font(.system(size: 8))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Avatars and Total Votes
            HStack(spacing: -8) {
                ForEach(0..<4) { i in
                    Image("ceo_profile_\(i + 1)")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                }
                
                Text("+\(totalVotes)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.purple.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                    .padding(.leading, 4)
                
                Text("Toplam \(totalVotes) CEO oy verdi")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.leading, 8)
            }
            
            // Join Button
            Button(action: onJoin) {
                HStack {
                    Text("Ankete Katıl")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "6C38FF"))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
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
