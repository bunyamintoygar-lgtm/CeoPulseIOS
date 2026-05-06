import SwiftUI

struct ProfileView: View {
    let interests = ["Dijital Dönüşüm", "Yapay Zeka", "Fintech", "Sürdürülebilirlik", "Liderlik", "İnovasyon", "İnsan Kaynakları"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("prof_title".localized())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: "square.grid.2x2")
                        Image(systemName: "gearshape")
                    }
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Profile Info Section
                HStack(alignment: .center, spacing: 20) {
                    // Avatar
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .stroke(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 3
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .padding(4)
                                    .clipShape(Circle())
                            )
                        
                        Circle()
                            .fill(Color.green)
                            .frame(width: 18, height: 18)
                            .overlay(Circle().stroke(AppColors.background, lineWidth: 3))
                            .offset(x: -5, y: -5)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Murat Korkmaz")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Text("CEO")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Korkmaz Holding")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                            Text("İstanbul, Türkiye")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top, 4)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "linkedin") // Placeholder
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text("prof_linkedin_verified".localized())
                                .font(.system(size: 11))
                                .foregroundColor(.blue.opacity(0.8))
                        }
                        .padding(.top, 2)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(action: {}) {
                            Text("prof_edit_button".localized())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.purple)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                        }
                        Spacer()
                    }
                    .frame(height: 100)
                }
                .padding(.horizontal, 20)
                
                // Premium Banner
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("prof_premium_member".localized())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("prof_premium_desc".localized())
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("prof_manage_premium".localized())
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(16)
                .background(AppColors.surface)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                // Stats Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ProfileStatMiniCard(value: "254", labelKey: "prof_stat_connections", iconName: "person.2.fill", iconColor: .purple)
                        ProfileStatMiniCard(value: "37", labelKey: "prof_stat_mutual", iconName: "person.3.fill", iconColor: .blue)
                        ProfileStatMiniCard(value: "12", labelKey: "prof_stat_requests", iconName: "bubble.left.fill", iconColor: .orange)
                        ProfileStatMiniCard(value: "28", labelKey: "prof_stat_surveys", iconName: "chart.bar.fill", iconColor: .green)
                        ProfileStatMiniCard(value: "9", labelKey: "prof_stat_roundtables", iconName: "calendar.badge.clock", iconColor: .yellow)
                    }
                    .padding(.horizontal, 20)
                }
                
                // About Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("prof_about_title".localized())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("20+ yıllık yöneticilik deneyimimle, sürdürülebilir büyüme, dijital dönüşüm ve insan odaklı liderlik konularına odaklanıyorum. İş dünyasındaki liderlerle bilgi paylaşımı yapmaktan ve ortak değer üretmekten büyük mutluluk duyuyorum.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(4)
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Text("prof_about_more".localized())
                                    Image(systemName: "chevron.down")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.purple)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            AboutInfoItem(icon: "briefcase", titleKey: "prof_sector", value: "Holding")
                            AboutInfoItem(icon: "building.2", titleKey: "prof_company_size", value: "1001+ çalışan")
                            AboutInfoItem(icon: "calendar", titleKey: "prof_joined_date", value: "Mart 2024")
                        }
                        .frame(width: 140)
                    }
                }
                .padding(.horizontal, 20)
                
                // Interests Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("prof_interests_title".localized())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("prof_edit_all".localized())
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    
                    // Simple Tag Layout (Wrapping or Horizontal Scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                ForEach(interests.prefix(5), id: \.self) { interest in
                                    Text(interest)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(AppColors.surface)
                                        .cornerRadius(12)
                                }
                            }
                            HStack(spacing: 8) {
                                ForEach(interests.suffix(2), id: \.self) { interest in
                                    Text(interest)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(AppColors.surface)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Premium Features Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 12))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("prof_premium_features_title".localized())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("prof_premium_features_desc".localized())
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Text("prof_all_advantages".localized())
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    // Feature Icons Row
                    HStack(spacing: 0) {
                        FeatureMiniItem(icon: "sparkles", title: "AI Insights", desc: "Sınırsız erişim")
                        FeatureMiniItem(icon: "chart.xyaxis.line", title: "Gelişmiş Analizler", desc: "Ayrıntılı raporlar")
                        FeatureMiniItem(icon: "bubble.left.and.bubble.right", title: "Ask Opinion", desc: "Sınırsız soru")
                        FeatureMiniItem(icon: "doc.text.fill", title: "Anket Geçmişi", desc: "Tüm sonuçlar")
                    }
                }
                .padding(20)
                .background(AppColors.surface.opacity(0.3))
                .cornerRadius(24)
                .padding(.horizontal, 20)
                
                // Activity Summary Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("prof_activity_summary".localized())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("Son 30 Gün")
                            Image(systemName: "chevron.down")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    }
                    
                    HStack(spacing: 12) {
                        ActivityCard(titleKey: "prof_survey_participation", value: "6", total: "8", progress: 0.75, labelKey: "%75", color: .purple)
                        ActivityCard(titleKey: "prof_roundtable_participation", value: "3", total: nil, progress: 0.4, labelKey: "prof_discussions", color: .green)
                        ActivityCard(titleKey: "prof_meeting_notifications", value: "14", total: nil, progress: 0.6, labelKey: "prof_new_meetings", color: .orange)
                    }
                }
                .padding(.horizontal, 20)
                
                // Menu Items
                VStack(spacing: 0) {
                    ProfileMenuItem(icon: "bookmark", titleKey: "prof_saved_content", value: "12")
                    Divider().background(Color.white.opacity(0.05))
                    ProfileMenuItem(icon: "shield", titleKey: "prof_privacy_settings", value: nil)
                    Divider().background(Color.white.opacity(0.05))
                    ProfileMenuItem(icon: "questionmark.circle", titleKey: "prof_help_support", value: nil)
                }
                .background(AppColors.surface)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct AboutInfoItem: View {
    let icon: String
    let titleKey: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppColors.textSecondary)
                .font(.system(size: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(titleKey.localized())
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                Text(value)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

struct FeatureMiniItem: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .font(.system(size: 16))
            }
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text(desc)
                .font(.system(size: 8))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let titleKey: String
    let value: String?
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.system(size: 18))
                .frame(width: 24)
            
            Text(titleKey.localized())
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            if let v = value {
                Text(v)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(16)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
