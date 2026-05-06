import SwiftUI

struct FeaturedRoundtableCard: View {
    let title: String
    let description: String
    let participantCount: Int
    let imageName: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image/Gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Image(systemName: "cpu") // Placeholder for AI/Tech icon
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.1))
                        .offset(x: 100, y: -40)
                )
            
            VStack(alignment: .leading, spacing: 16) {
                // Badge
                Text("rt_active_discussion".localized())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.5))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                HStack {
                    // Participants
                    HStack(spacing: -8) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 28, height: 28)
                                .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 1))
                        }
                        Text("+24")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color.indigo)
                            .clipShape(Capsule())
                    }
                    
                    Text("\(participantCount) \("rt_participants".localized())")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    NavigationLink(destination: JoinRoundtableView()) {
                        HStack {
                            Text("rt_join_discussion".localized())
                                .font(.system(size: 14, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "7B61FF"), Color(hex: "A389FF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "7B61FF").opacity(0.3), radius: 8, y: 4)
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 240)
        .background(AppColors.surface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct FeaturedRoundtableCard_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedRoundtableCard(
            title: "Yapay Zeka Çağında Liderlik: Stratejilerimiz Nasıl Değişmeli?",
            description: "AI dönüşümü, liderlik yetkinliklerini ve organizasyon kültürünü nasıl yeniden şekillendiriyor?",
            participantCount: 28,
            imageName: "ai_meeting"
        )
        .padding()
        .background(AppColors.background)
    }
}
