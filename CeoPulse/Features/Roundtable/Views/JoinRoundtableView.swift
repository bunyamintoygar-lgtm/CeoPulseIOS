import SwiftUI

struct JoinRoundtableView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("rt_join_title".localized())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Hero Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Liderlik & Strateji")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("2025’te Sürdürülebilir Büyüme Stratejileri")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                            Text("24 Mayıs 2025, Cumartesi")
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                            Text("20:30 – 22:00 (90 dk)")
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: -8) {
                            ForEach(0..<4) { _ in
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(AppColors.surface, lineWidth: 2))
                            }
                            ZStack {
                                Circle()
                                    .fill(Color.indigo)
                                    .frame(width: 32, height: 32)
                                Text("+12")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("Ali Yılmaz ve 15 diğer uzman")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        AppColors.surface
                        // Simplified placeholder for the roundtable illustration
                        Image(systemName: "circle.grid.3x3.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150)
                            .foregroundColor(.purple.opacity(0.1))
                            .offset(x: 100, y: 0)
                    }
                )
                .cornerRadius(24)
                .padding(.horizontal, 20)
                
                // Info Alert
                HStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.purple)
                    Text("rt_join_limit_info".localized())
                        .font(.system(size: 12))
                        .foregroundColor(.purple.opacity(0.9))
                    Spacer()
                }
                .padding(16)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Before Joining Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("rt_before_join".localized())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        JoinInfoCard(icon: "person.3.fill", title: "rt_before_1_title".localized(), desc: "rt_before_1_desc".localized())
                        JoinInfoCard(icon: "bubble.left.fill", title: "rt_before_2_title".localized(), desc: "rt_before_2_desc".localized())
                        JoinInfoCard(icon: "target", title: "rt_before_3_title".localized(), desc: "rt_before_3_desc".localized())
                    }
                }
                .padding(.horizontal, 20)
                
                // Agenda Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("rt_what_happens".localized())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        AgendaRow(text: "rt_agenda_1".localized())
                        AgendaRow(text: "rt_agenda_2".localized())
                        AgendaRow(text: "rt_agenda_3".localized())
                        AgendaRow(text: "rt_agenda_4".localized())
                    }
                    .padding(20)
                    .background(AppColors.surface)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                
                // Rules Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("rt_rules_title".localized())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        RuleRow(icon: "mic.slash.fill", text: "rt_rule_1".localized())
                        RuleRow(icon: "person.fill", text: "rt_rule_2".localized())
                        RuleRow(icon: "heart.fill", text: "rt_rule_3".localized())
                        RuleRow(icon: "shield.fill", text: "rt_rule_4".localized())
                    }
                    .padding(20)
                    .background(AppColors.surface)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                
                // Capacity & Footer
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack {
                            Text("rt_capacity_status".localized())
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("18 / 20")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.05))
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(AppColors.primary)
                                    .frame(width: geo.size.width * 0.9)
                            }
                        }
                        .frame(height: 6)
                    }
                    
                    NavigationLink(destination: ActiveSessionView()) {
                        HStack {
                            Text("rt_join_title".localized())
                                .font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
                        .cornerRadius(16)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                        Text("rt_accept_rules_info".localized())
                    }
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct JoinInfoCard: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .font(.system(size: 20))
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(desc)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct AgendaRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.indigo)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
            Spacer()
        }
    }
}

struct RuleRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.indigo)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
}

struct JoinRoundtableView_Previews: PreviewProvider {
    static var previews: some View {
        JoinRoundtableView()
    }
}
