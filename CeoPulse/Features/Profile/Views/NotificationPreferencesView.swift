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
                        
                        // Notification Channels
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: NSLocalizedString("notifications_channels", comment: ""), subtitle: NSLocalizedString("notifications_channels_subtitle", comment: ""))
                            
                            VStack(spacing: 1) {
                                NotificationToggleRow(icon: "bell", title: NSLocalizedString("notification_push_title", comment: ""), subtitle: NSLocalizedString("notification_push_subtitle", comment: ""), isOn: $inAppNotifications)
                                NotificationToggleRow(icon: "envelope", title: NSLocalizedString("notification_email_title", comment: ""), subtitle: NSLocalizedString("notification_email_subtitle", comment: ""), isOn: $emailNotifications)
                            }
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                        }
                        
                        // Notification Categories
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: NSLocalizedString("notifications_categories", comment: ""), subtitle: NSLocalizedString("notifications_categories_subtitle", comment: ""))
                            
                            VStack(spacing: 1) {
                                NotificationToggleRow(icon: "star", title: NSLocalizedString("notification_network_title", comment: ""), subtitle: NSLocalizedString("notification_network_subtitle", comment: ""), isOn: $networkActivity)
                                NotificationToggleRow(icon: "briefcase", title: NSLocalizedString("notification_jobs_title", comment: ""), subtitle: NSLocalizedString("notification_jobs_subtitle", comment: ""), isOn: $jobOpportunities)
                                NotificationToggleRow(icon: "chart.bar", title: NSLocalizedString("notification_events_title", comment: ""), subtitle: NSLocalizedString("notification_events_subtitle", comment: ""), isOn: $events)
                                NotificationToggleRow(icon: "doc.text", title: NSLocalizedString("notification_updates_title", comment: ""), subtitle: NSLocalizedString("notification_updates_subtitle", comment: ""), isOn: $platformUpdates)
                                NotificationToggleRow(icon: "megaphone", title: NSLocalizedString("notification_marketing_title", comment: ""), subtitle: NSLocalizedString("notification_marketing_subtitle", comment: ""), isOn: $marketing)
                            }
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                        }
                        
                        // Privacy Note
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.purple)
                            Text(NSLocalizedString("notifications_privacy_note", comment: ""))
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
