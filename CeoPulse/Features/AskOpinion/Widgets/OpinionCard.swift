import SwiftUI

struct OpinionCard: View {
    let opinion: Opinion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Row: Status, Time, Category, Bookmark
            HStack {
                HStack(spacing: 8) {
                    Text(opinion.status.title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(opinion.status == .open ? .green : .blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(opinion.status == .open ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    
                    Text("• \(opinion.timeAgo)")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(opinion.category)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "A855F7")) // Purple-ish
                    
                    Image(systemName: opinion.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Author Row
            HStack(spacing: 12) {
                if let avatar = opinion.authorAvatar {
                    // Avatar implementation
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 16))
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(opinion.authorName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text(opinion.authorTitle)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            // Question Text
            Text(opinion.question)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Stats Row & Action Button
            HStack {
                HStack(spacing: 16) {
                    Label("\(opinion.viewCount)", systemImage: "eye")
                    Label("\(opinion.responseCount)", systemImage: "bubble.left")
                    Label("\(opinion.saveCount)", systemImage: "bookmark")
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                if opinion.status == .open {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("Yanıtla")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("Sonuçları Gör")
                            Image(systemName: "chart.bar.fill")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
