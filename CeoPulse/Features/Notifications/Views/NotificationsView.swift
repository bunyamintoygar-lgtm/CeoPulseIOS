import SwiftUI

struct NotificationsView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .symbolEffect(.pulse, options: .repeating)
                
                Text("Bildirimler")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Önemli güncellemeler ve anket sonuçları burada görünecek.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer().frame(height: 40)
                
                VStack(spacing: 12) {
                    NotificationPlaceholderRow(title: "Yeni Anket Yayında", desc: "Yapay zeka ve gelecek vizyonu anketi başladı.", time: "Şimdi")
                    NotificationPlaceholderRow(title: "Profil Doğrulaması", desc: "LinkedIn hesabınız başarıyla doğrulandı.", time: "2 saat önce")
                    NotificationPlaceholderRow(title: "Anket Sonucu", desc: "Katıldığınız 'Hibrit Çalışma' anketi sonuçlandı.", time: "Dün")
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 60)
        }
    }
}

struct NotificationPlaceholderRow: View {
    let title: String
    let desc: String
    let time: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "bell.fill").foregroundColor(.purple).font(.system(size: 16)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
}
