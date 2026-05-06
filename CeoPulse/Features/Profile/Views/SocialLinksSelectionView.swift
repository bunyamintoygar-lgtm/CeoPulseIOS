import SwiftUI

struct SocialLinksSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Platforms to add
    let platforms = [
        SocialPlatform(name: "LinkedIn", description: "Profesyonel ağınızı gösterin", icon: "linkedin_icon", actionType: .connect),
        SocialPlatform(name: "Web Sitesi", description: "Kişisel veya kurumsal web siteniz", icon: "globe", actionType: .add),
        SocialPlatform(name: "X (Twitter)", description: "Güncel paylaşımlarınızı gösterin", icon: "x_icon", actionType: .connect),
        SocialPlatform(name: "Instagram", description: "Profesyonel içeriklerinizi paylaşın", icon: "instagram_icon", actionType: .connect),
        SocialPlatform(name: "YouTube", description: "Videolarınızı ve içeriklerinizi paylaşın", icon: "youtube_icon", actionType: .connect),
        SocialPlatform(name: "Medium", description: "Yazılarınızı ve makalelerinizi ekleyin", icon: "medium_icon", actionType: .add),
        SocialPlatform(name: "GitHub", description: "Projelerinizi ve katkılarınızı paylaşın", icon: "github_icon", actionType: .add),
        SocialPlatform(name: "Behance", description: "Tasarım ve proje çalışmalarınızı ekleyin", icon: "behance_icon", actionType: .add)
    ]
    
    // Mock connected accounts
    @State private var connectedAccounts = [
        ConnectedAccount(platform: "LinkedIn", handle: "linkedin.com/in/kullaniciadi", visibility: .public),
        ConnectedAccount(platform: "Web Sitesi", handle: "www.kullaniciadi.com", visibility: .public),
        ConnectedAccount(platform: "Instagram", handle: "@kullaniciadi", visibility: .private)
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Section
                        VStack(spacing: 8) {
                            Text("Sosyal Bağlantılarınızı Ekleyin")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text("Sosyal profilleriniz, profesyonel ağınızı genişletmenize ve fırsatları artırmanıza yardımcı olur.")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.purple)
                            Text("Bağladığınız hesaplar profilinizde isteğinize bağlı olarak gösterilir.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        
                        // Add Links Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Bağlantı Ekle")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ForEach(platforms) { platform in
                                    PlatformRow(platform: platform)
                                }
                            }
                        }
                        
                        // Connected Accounts Section
                        if !connectedAccounts.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Bağlanan Hesaplar")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    ForEach(connectedAccounts) { account in
                                        ConnectedAccountRow(account: account)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
                // Footer
                VStack(spacing: 12) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Text("Kaydet ve Devam Et")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C38FF"))
                        .cornerRadius(12)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Bağlantılarınızı dilediğiniz zaman düzenleyebilirsiniz.")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                .padding(24)
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

// MARK: - Models & Components

struct SocialPlatform: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let actionType: ActionType
    
    enum ActionType: String {
        case connect = "Bağla"
        case add = "Ekle"
    }
}

struct ConnectedAccount: Identifiable {
    let id = UUID()
    let platform: String
    let handle: String
    let visibility: Visibility
    
    enum Visibility: String {
        case `public` = "Görünüyor"
        case `private` = "Sadece ben"
    }
}

struct PlatformRow: View {
    let platform: SocialPlatform
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 44, height: 44)
                
                // Use system icons or placeholders for now
                Image(systemName: platform.icon == "globe" ? "globe" : "person.crop.circle")
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(platform.name).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(platform.description).font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Button(platform.actionType.rawValue) {}
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
}

struct ConnectedAccountRow: View {
    let account: ConnectedAccount
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue) // Placeholder for platform color
                .frame(width: 40, height: 40)
            
            Text(account.handle)
                .font(.system(size: 13))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(account.visibility.rawValue)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(account.visibility == .public ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                .foregroundColor(account.visibility == .public ? .green : .orange)
                .cornerRadius(6)
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}
