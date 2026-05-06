import SwiftUI

struct RoundtableRow: View {
    let title: String
    let status: String
    let statusColor: Color
    let participantCount: Int
    let commentCount: Int
    let activityText: String
    let imageName: String
    let dateText: String?
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "photo")
                    .foregroundColor(.white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(status)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Image(systemName: "bookmark")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let date = dateText {
                    Text(date)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                HStack(spacing: 12) {
                    // Avatars
                    HStack(spacing: -6) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 18, height: 18)
                        }
                    }
                    
                    Text("\(participantCount) \("rt_participants".localized())")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                    
                    if commentCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left.fill")
                            Text("\(commentCount)")
                        }
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            VStack {
                Spacer()
                Text(activityText)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
                Spacer()
            }
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
