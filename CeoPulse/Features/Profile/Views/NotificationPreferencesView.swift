import SwiftUI

struct NotificationPreferencesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Channel States
    @State private var inAppNotifications = true
    @State private var emailNotifications = true
    
    // Category States
    @State private var networkActivity = true
    @State private var jobOpportunities = true
    @State private var events = true
    @State private var platformUpdates = true
    @State private var marketing = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Title Section
                        VStack(spacing: 12) {
                            Text(NSLocalizedString("notifications_title", comment: ""))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text(NSLocalizedString("notifications_subtitle", comment: ""))
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Channels Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("notifications_channels", comment: ""))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 0) {
                                NotificationToggleRow(title: "Push Bildirimleri", subtitle: "Anlık gelişmelerden haberdar olun", isOn: .constant(true))
                                Divider().background(Color.white.opacity(0.05))
                                NotificationToggleRow(title: "E-posta", subtitle: "Önemli özetleri e-posta ile alın", isOn: .constant(false))
                                Divider().background(Color.white.opacity(0.05))
                                NotificationToggleRow(title: "SMS", subtitle: "Kritik güvenlik uyarıları için", isOn: .constant(false))
                            }
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(12)
                        }
                        
                        // Categories Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("notifications_categories", comment: ""))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 0) {
                                NotificationToggleRow(title: "Etkinlikler", subtitle: "Yeni etkinlik ve organizasyonlar", isOn: .constant(true))
                                Divider().background(Color.white.opacity(0.05))
                                NotificationToggleRow(title: "Haberler & Duyurular", subtitle: "Sektörel haberler ve uygulama duyuruları", isOn: .constant(true))
                                Divider().background(Color.white.opacity(0.05))
                                NotificationToggleRow(title: "Ağ Gelişmeleri", subtitle: "Yeni bağlantılar ve etkileşimler", isOn: .constant(true))
                            }
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(12)
                        }
                        
                        // Info Box
                        HStack(spacing: 16) {
                            
                            Spacer()
                            
                            ZStack {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.purple)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .background(Circle().fill(.purple))
                                    .offset(x: 10, y: 10)
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple.opacity(0.1), lineWidth: 1))
                        
                        // Notification Channels
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Bildirim Kanalları", subtitle: "Hangi kanallardan bildirim almak istediğinizi seçin.")
                            
                            VStack(spacing: 1) {
                                NotificationToggleRow(icon: "bell", title: "Uygulama İçi Bildirimler", subtitle: "CEO Pulse uygulaması içindeki bildirimler", isOn: $inAppNotifications)
                                NotificationToggleRow(icon: "envelope", title: "E-posta Bildirimleri", subtitle: "E-posta adresinize gönderilecek bildirimler", isOn: $emailNotifications)
                            }
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                        }
                        
                        // Notification Categories
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Bildirim Kategorileri", subtitle: "Hangi tür bildirimler almak istediğinizi seçin.")
                            
                            VStack(spacing: 1) {
                                NotificationToggleRow(icon: "star", title: "İlişkiler ve Ağ", subtitle: "Yeni bağlantı istekleri, mesajlar ve ağ aktiviteleri", isOn: $networkActivity)
                                NotificationToggleRow(icon: "briefcase", title: "İş Fırsatları", subtitle: "İş ilanları, ortaklık teklifleri ve fırsat önerileri", isOn: $jobOpportunities)
                                NotificationToggleRow(icon: "chart.bar", title: "Etkinlikler", subtitle: "Etkinlik davetleri, hatırlatmalar ve güncellemeler", isOn: $events)
                                NotificationToggleRow(icon: "doc.text", title: "Platform Güncellemeleri", subtitle: "Yeni özellikler, iyileştirmeler ve duyurular", isOn: $platformUpdates)
                                NotificationToggleRow(icon: "megaphone", title: "Pazarlama ve Kampanyalar", subtitle: "Özel kampanyalar, ipuçları ve içerik önerileri", isOn: $marketing)
                            }
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                        }
                        
                        // Privacy Note
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.purple)
                            Text("Bildirim ayarlarınız gizlidir ve üçüncü kişilerle paylaşılmaz.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
                // Footer
                VStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Text("Devam Et")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C38FF"))
                        .cornerRadius(12)
                    }
                    .padding(24)
                }
                .background(AppColors.background)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
            Spacer()
            Image("ceopulse_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

// MARK: - Components

struct SectionHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            Text(subtitle).font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
        }
    }
}

struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(.purple)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    Text(subtitle).font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "6C38FF")))
                    .labelsHidden()
            }
            .padding()
            
            Divider()
                .background(Color.white.opacity(0.05))
                .padding(.leading, 72)
        }
    }
}
