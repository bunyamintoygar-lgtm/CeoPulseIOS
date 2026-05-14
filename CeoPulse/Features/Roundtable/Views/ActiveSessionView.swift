import SwiftUI
import Combine
import Supabase

struct ActiveSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: ActiveSessionViewModel
    @State private var messageText = ""
    
    init(roundtable: Roundtable) {
        _viewModel = StateObject(wrappedValue: ActiveSessionViewModel(roundtable: roundtable))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Button(action: { 
                        viewModel.leaveSession()
                        presentationMode.wrappedValue.dismiss() 
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("rt_active_title".localized())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text(viewModel.roundtable.title)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Button(action: { 
                            viewModel.leaveSession()
                            presentationMode.wrappedValue.dismiss() 
                        }) {
                            Text("rt_leave_table".localized())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                }
                
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(viewModel.roundtable.startTime.formatted(date: .long, time: .omitted))
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(viewModel.roundtable.startTime.formatted(date: .omitted, time: .shortened))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 6, height: 6)
                        Text("rt_live".localized())
                            .foregroundColor(.white)
                    }
                    .font(.system(size: 11, weight: .bold))
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            // Participant Area (Circular Table)
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                        Text("\(viewModel.participants.count) / 20 \("rt_participants".localized())")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.3.sequence.fill")
                            Text("rt_see_participants".localized())
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                
                // The Table
                ZStack {
                    // Table Base
                    Circle()
                        .fill(
                            RadialGradient(colors: [Color.purple.opacity(0.2), Color.clear], center: .center, startRadius: 0, endRadius: 120)
                        )
                        .frame(width: 280, height: 280)
                    
                    // Table Visualization (Inner)
                    ZStack {
                        Circle()
                            .stroke(Color.purple.opacity(0.3), lineWidth: 4)
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .stroke(Color.purple, lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .shadow(color: .purple, radius: 10)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("rt_request_floor".localized())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Avatars around the table (Dynamic)
                    ForEach(Array(viewModel.participants.enumerated()), id: \.element.id) { index, participant in
                        ParticipantAvatarView(
                            name: participant.userName ?? "Lider",
                            role: participant.role.title,
                            roleColor: participant.role.color,
                            isMuted: participant.isMuted,
                            angle: Double(index) * (360.0 / Double(max(1, viewModel.participants.count))) - 90,
                            isMe: participant.userId == viewModel.currentUserId
                        )
                    }
                    
                    if viewModel.participants.isEmpty {
                        Text("Masada kimse yok...")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 320)
                
                // Legend
                HStack(spacing: 20) {
                    LegendItem(icon: "mic.fill", color: .purple, text: "rt_status_speaker".localized())
                    LegendItem(icon: "hand.raised.fill", color: .green, text: "rt_status_floor_is_yours".localized())
                    LegendItem(icon: "mic.slash.fill", color: .gray, text: "rt_status_muted".localized())
                }
                .font(.system(size: 11))
            }
            .padding(.bottom, 20)
            
            // Tabs & Chat
            VStack(spacing: 0) {
                // Custom Tabs
                HStack(spacing: 0) {
                    SessionTabItem(title: "rt_tab_chat".localized(), isSelected: true) { } // Simple mock for now
                    SessionTabItem(title: "rt_tab_insights".localized(), isSelected: false) { }
                    SessionTabItem(title: "rt_tab_notes".localized(), isSelected: false) { }
                    SessionTabItem(title: "rt_tab_surveys".localized(), isSelected: false) { }
                }
                .padding(.horizontal, 20)
                
                Divider().background(Color.white.opacity(0.1))
                
                // Chat List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            ChatRow(
                                name: message.userName ?? "Kullanıcı",
                                role: "Katılımcı",
                                roleColor: .blue,
                                message: message.content,
                                time: message.createdAt.formatted(date: .omitted, time: .shortened)
                            )
                        }
                        
                        if viewModel.messages.isEmpty {
                            Text("Sohbeti başlatın...")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        }
                    }
                    .padding(20)
                }
                
                // Input Area
                HStack(spacing: 12) {
                    HStack {
                        TextField("rt_chat_placeholder".localized(), text: $messageText)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        
                        Button(action: {}) {
                            Image(systemName: "paperclip")
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(24)
                    
                    Button(action: {
                        Task {
                            await viewModel.sendMessage(messageText)
                            messageText = ""
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 44, height: 44)
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(AppColors.surface)
            .cornerRadius(32, corners: [.topLeft, .topRight])
            
            // Bottom Controls
            HStack(spacing: 0) {
                ControlCircleButton(icon: "mic.slash.fill", label: "rt_control_mic".localized(), color: .red)
                ControlCircleButton(icon: "video.slash.fill", label: "rt_control_cam".localized(), color: .gray)
                
                // Request Floor Main Button
                Button(action: {}) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 56, height: 56)
                                .overlay(Circle().stroke(Color.purple.opacity(0.3), lineWidth: 1))
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.purple)
                        }
                        Text("rt_request_floor".localized())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.purple)
                    }
                }
                .frame(maxWidth: .infinity)
                
                ControlCircleButton(icon: "face.smiling", label: "rt_control_reaction".localized(), color: .gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppColors.background)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.setupSession()
        }
    }
}

struct ParticipantAvatarView: View {
    let name: String
    let role: String
    let roleColor: Color
    let isMuted: Bool
    let angle: Double
    var isMe: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(isMe ? Color.green : Color.clear, lineWidth: 2)
                    )
                
                ZStack {
                    Circle()
                        .fill(isMuted ? Color.gray : Color.purple)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                    Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 0) {
                Text(name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isMe ? .green : .white)
                Text(role)
                    .font(.system(size: 9))
                    .foregroundColor(roleColor)
            }
        }
        .offset(x: 110 * cos(angle * .pi / 180), y: 110 * sin(angle * .pi / 180))
    }
}

struct LegendItem: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

struct SessionTabItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .purple : AppColors.textSecondary)
                
                Rectangle()
                    .fill(isSelected ? .purple : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ChatRow: View {
    let name: String
    let role: String
    let roleColor: Color
    let message: String
    let time: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(role)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(roleColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(roleColor.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(time)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
        }
    }
}

struct ControlCircleButton: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActiveSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveSessionView(roundtable: .mock)
    }
}