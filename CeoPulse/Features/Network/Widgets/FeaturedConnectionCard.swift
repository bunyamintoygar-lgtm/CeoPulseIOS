import SwiftUI

struct FeaturedConnectionCard: View {
    let name: String
    let title: String
    let company: String
    let imageName: String
    let isOnline: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Avatar with online status
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                if isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(AppColors.surface, lineWidth: 2))
                        .offset(x: -4, y: 4)
                }
                
                // LinkedIn icon placeholder
                Image(systemName: "linkedin")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .offset(x: 2, y: 60)
            }
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(company)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Button(action: {}) {
                Text("net_view_profile".localized())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.primaryAccent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.primaryAccent.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primaryAccent.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(16)
        .frame(width: 140)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
