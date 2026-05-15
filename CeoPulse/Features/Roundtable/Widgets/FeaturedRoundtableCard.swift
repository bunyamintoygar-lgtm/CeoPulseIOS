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
                
                // Supabase Image for Roundtable
                AsyncImage(url: URL(string: "https://wvsbpsahpshgmrgcxpmq.supabase.co/storage/v1/object/public/app_assets/roundtable.png")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160)
                } placeholder: {
                    Color.clear
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: 10)
                .opacity(0.9)
            }
            .frame(height: 220)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Yeni bir yuvarlak masa oluşturun")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Uzmanları ve liderleri bir araya getirerek fikir alışverişinde bulunun, yeni bakış açıları kazanın.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(3)
                        .frame(maxWidth: 220)
                }
                .padding(.bottom, 8)
                
                Button(action: { /* Create action */ }) {
                    HStack(spacing: 8) {
                        Text("Yuvarlak Masa Oluştur")
                        Image(systemName: "plus.circle")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(12)
                    .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
                }
            }
            .padding(24)
        }
    }
}
