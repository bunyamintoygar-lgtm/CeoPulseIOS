import SwiftUI

struct PastRoundtableCard: View {
    let title: String
    let date: String
    let category: String
    let duration: String
    let imageName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                // Background Image
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface)
                    .frame(width: 160, height: 100)
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.8))
                
                // Category Tag
                VStack {
                    HStack {
                        Text(category)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primaryAccent.opacity(0.8))
                            .cornerRadius(6)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
                
                // Duration Tag
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                    }
                }
                .padding(8)
            }
            .frame(width: 160, height: 100)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(date)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(width: 160)
    }
}
