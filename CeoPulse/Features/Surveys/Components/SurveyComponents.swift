import SwiftUI

struct SurveyCard: View {
    let survey: Survey
    let totalVotes: Int
    let participationRate: Double // 0.0 to 1.0
    let timeRemaining: String
    let isAnonymous: Bool
    let buttonTitle: String
    let onJoin: () -> Void
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @ObservedObject var configManager = ConfigManager.shared
    
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
                            Text(LocalizedStringKey("survey_anonymous"))
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .symbolRenderingMode(.hierarchical)
                    Text(timeRemaining)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            }
            
            // Middle Content: Title and Progress
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(survey.title)
                        .font(.system(size: 16, weight: .bold)) // Reduced from 18
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    // Category only
                    if let category = configManager.surveyCategories.first(where: { $0.id == survey.categoryId }) {
                        Text(category.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Participation Rate Circle (Larger)
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 8)
                        .frame(width: 90, height: 90)
                    
                    Circle()
                        .trim(from: 0, to: participationRate > 0 ? participationRate : 0.05)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, Color(hex: "6C38FF"), .blue],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: .purple.opacity(0.2), radius: 4)
                    
                    VStack(spacing: 0) {
                        Text("%\(Int(participationRate * 100))")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                        Text(LocalizedStringKey("survey_total_participation"))
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Voter Avatars Row
            HStack(spacing: 12) {
                if totalVotes > 0 {
                    HStack(spacing: -10) {
                        let avatarCount = min(totalVotes, 4)
                        ForEach(0..<avatarCount, id: \.self) { i in
                            Image("ceo_profile_\(i + 1)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "121217"), lineWidth: 2))
                        }
                        
                        if totalVotes > 4 {
                            Text("+\(totalVotes - 4)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(Color.purple.opacity(0.4)))
                                .overlay(Circle().stroke(Color(hex: "121217"), lineWidth: 2))
                        }
                    }
                }
                
                Spacer()
                
                // Creation Date Aligned to Right
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text(survey.createdAt.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Main Action (Join/Results)
                Button(action: onJoin) {
                    HStack {
                        Text(survey.status == .rejected ? NSLocalizedString("survey_status_rejected", comment: "") : buttonTitle)
                            .font(.system(size: 16, weight: .bold))
                        if survey.status != .rejected {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        survey.status == .rejected ?
                        AnyView(Color.red.opacity(0.8)) :
                        AnyView(LinearGradient(
                            colors: [Color(hex: "6C38FF"), .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    )
                    .cornerRadius(16)
                    .shadow(color: (survey.status == .rejected ? Color.red : Color(hex: "6C38FF")).opacity(0.3), radius: 10, y: 5)
                }
                
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                }
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.red)
                            .cornerRadius(16)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(hex: "121217").opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(colors: [.white.opacity(0.15), .clear, .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
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
    var statusBadge: String? = nil
    var statusColor: Color? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
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
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(date)
                    
                    if let badge = statusBadge, let badgeColor = statusColor {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(badgeColor.opacity(0.2))
                            .foregroundColor(badgeColor)
                            .cornerRadius(4)
                    }
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer(minLength: 8)
            
            if onEdit != nil || onDelete != nil {
                HStack(spacing: 8) {
                    if let editAction = onEdit {
                        Button(action: editAction) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    if let deleteAction = onDelete {
                        Button(action: deleteAction) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            } else {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("%\(rate)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                    Text(LocalizedStringKey("survey_participation_rate_label"))
                        .font(.system(size: 8))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.leading, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.02))
        .cornerRadius(16)
    }
}
