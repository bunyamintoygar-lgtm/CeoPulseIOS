import SwiftUI

struct UserProfileSection: View {
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image with LinkedIn Badge
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "person.crop.circle.fill") // Placeholder for real image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 2))
                
                // LinkedIn Logo Placeholder
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                    Text("in")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 2, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("greeting".localized(with: ["Ali Yılmaz"]))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("CEO @ PulseTech")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("“Bağlantılar güçtür, içgörü ise avantaj.”")
                    .font(.system(size: 12, weight: .medium))
                    .italic()
                    .foregroundColor(AppColors.textSecondary.opacity(0.8))
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, 8)
    }
}

struct UserProfileSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            UserProfileSection()
                .padding()
        }
    }
}
