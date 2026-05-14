import SwiftUI

struct FeaturedRoundtableCard: View {
    let roundtable: Roundtable
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image/Gradient
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "13141C"))
                
                // Glow effect
                Circle()
                    .fill(AppColors.primaryAccent.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 100, y: -50)
                
                // Use the generated image if available, else a gradient placeholder
                Image("roundtable_hero_render_1778791841770") // Use the actual generated image name
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 400, height: 220)
                    .clipped()
                    .opacity(0.8)
                    .mask(
                        LinearGradient(
                            colors: [.black, .black, .clear],
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                    .offset(x: 60)
            }
            .frame(height: 220)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Yuvarlak Masaya Katıl")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Uzmanlar ve liderlerle bir araya gelin, fikir alışverişinde bulunun, yeni bakış açıları kazanın.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(3)
                        .frame(maxWidth: 200)
                }
                
                NavigationLink(destination: JoinRoundtableView(roundtable: roundtable)) {
                    HStack(spacing: 8) {
                        Text("Masaya Katıl")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryAccent)
                    .cornerRadius(12)
                    .shadow(color: AppColors.primaryAccent.opacity(0.3), radius: 10, y: 5)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                    Text("Katılım kontenjanla sınırlıdır. Erken katıl, yerini ayırt!")
                        .font(.system(size: 10))
                }
                .foregroundColor(AppColors.primaryAccent.opacity(0.8))
                .padding(.top, 4)
            }
            .padding(24)
        }
    }
}
