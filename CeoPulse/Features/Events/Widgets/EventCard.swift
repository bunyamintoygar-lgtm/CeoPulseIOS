import SwiftUI

struct EventCard: View {
    let title: String
    let category: String
    let date: String
    let time: String
    let location: String
    let description: String
    let imageName: String
    let participantCount: Int
    let actionLabel: String
    let isBookmarked: Bool
    let categoryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Event Image
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "photo") // Placeholder
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    // Participant Avatars (simplified)
                    HStack(spacing: -8) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(AppColors.surface, lineWidth: 1))
                        }
                        Text("+\(participantCount)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .padding(6)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(category)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(categoryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor.opacity(0.1))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label(date, systemImage: "calendar")
                        Label(time, systemImage: "clock")
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(16)
            
            HStack {
                Spacer()
                Button(action: {}) {
                    HStack {
                        Text(actionLabel)
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(AppColors.surface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct EventCard_Previews: PreviewProvider {
    static var previews: some View {
        EventCard(
            title: "Liderler Zirvesi 2025",
            category: "Zirve",
            date: "24 Mayıs 2025",
            time: "09:00 - 17:30",
            location: "Raffles Hotel, İstanbul",
            description: "Türkiye ve dünyadan liderlerle bir araya gelerek geleceği konuşuyoruz.",
            imageName: "bridge",
            participantCount: 124,
            actionLabel: "Detayları Gör",
            isBookmarked: false,
            categoryColor: .purple
        )
        .padding()
        .background(AppColors.background)
    }
}
