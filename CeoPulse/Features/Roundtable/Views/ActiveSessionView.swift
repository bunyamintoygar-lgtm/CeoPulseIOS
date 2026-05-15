import SwiftUI
import Combine
import Supabase

struct ActiveSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: ActiveSessionViewModel
    @State private var messageText = ""
    @State private var selectedTab = 0
    @State private var isFloorRequested = false
    
    init(roundtable: Roundtable) {
        _viewModel = StateObject(wrappedValue: ActiveSessionViewModel(roundtable: roundtable))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Event Details Bar
            eventDetailsBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Circular Roundtable Area
                    roundtableArea
                    
                    // Participant Thumbnail Strip
                    participantStrip
                    
                    // Main Content (Tabs & Chat)
                    contentSection
                }
                .padding(.top, 10)
            }
            
            // Bottom Action Bar
            bottomActionBar
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.setupSession()
        }
        .onDisappear {
            viewModel.leaveSession()
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            Button(action: { 
                viewModel.leaveSession()
                presentationMode.wrappedValue.dismiss() 
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Masaya Katıl")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text(viewModel.roundtable.title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var eventDetailsBar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.6))
                Text(viewModel.roundtable.startTime.formatted(date: .long, time: .omitted))
                    .font(.system(size: 11))
            }
            .padding(.trailing, 16)
            
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.white.opacity(0.6))
                Text(viewModel.roundtable.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11))
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text("Canlı")
                    .font(.system(size: 11, weight: .bold))
            }
        }
        .foregroundColor(.white.opacity(0.9))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private var roundtableArea: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                    Text("\(viewModel.participants.count) / 40 Katılımcı")
                }
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.sequence.fill")
                        Text("Katılımcıları Gör")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.purple)
                }
            }
            .padding(.horizontal, 20)
            
            ZStack {
                Circle()
                    .fill(Color(hex: "0F0F1A"))
                    .frame(width: 200, height: 200)
                    .shadow(color: .purple.opacity(0.3), radius: 30)
                
                Button(action: { 
                    withAnimation { isFloorRequested.toggle() } 
                    viewModel.requestFloor()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 32))
                        Text("Söz İste")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(
                        ZStack {
                            Circle().fill(Color.purple.opacity(0.3))
                            Circle().stroke(Color.purple, lineWidth: 2)
                                .scaleEffect(isFloorRequested ? 1.2 : 1.0)
                                .opacity(isFloorRequested ? 0 : 1)
                        }
                    )
                }
                
                // Dynamic Avatars
                ForEach(Array(viewModel.participants.enumerated()), id: \.element.id) { index, participant in
                    let angle = Double(index) * (360.0 / Double(max(1, viewModel.participants.count))) - 90
                    participantAvatar(
                        name: participant.userName ?? "Lider",
                        role: participant.role.title,
                        roleColor: participant.role.color,
                        isMuted: participant.isMuted,
                        angle: angle,
                        isSpeaking: false, // In a real app, bind to Agora's speaking detection
                        isMe: participant.userId == viewModel.currentUserId
                    )
                }
            }
            .frame(height: 340)
            
            // Legend
            HStack(spacing: 24) {
                Label("Konuşmacı", systemImage: "mic.fill").foregroundColor(.purple)
                Label("Söz Hakkı Sırada", systemImage: "circle.dotted").foregroundColor(.green)
                Label("Sessizde", systemImage: "mic.slash.fill").foregroundColor(.gray)
            }
            .font(.system(size: 10))
        }
    }
    
    private var participantStrip: some View {
        VStack(spacing: 12) {
            HStack(spacing: -8) {
                ForEach(viewModel.participants.prefix(12)) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                }
                if viewModel.participants.count > 12 {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                        Text("+\(viewModel.participants.count - 12)")
                            .font(.system(size: 10, weight: .bold))
                    }
                }
            }
            
            Text("Tüm katılımcıları görmek için listeyi açın.")
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text("Tüm Katılımcılar")
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.purple)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var contentSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButton(title: "Sohbet", index: 0)
                tabButton(title: "İçgörüler", index: 1)
                tabButton(title: "Notlar", index: 2)
                tabButton(title: "Anketler", index: 3)
            }
            .padding(.horizontal, 20)
            
            Divider().background(Color.white.opacity(0.1))
            
            if selectedTab == 0 {
                // Chat List
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.messages) { message in
                            chatRow(
                                name: message.userName ?? "Kullanıcı",
                                role: "Katılımcı",
                                color: .blue,
                                message: message.content,
                                time: message.createdAt.formatted(date: .omitted, time: .shortened)
                            )
                        }
                    }
                    .padding(20)
                }
                
                // Message Input
                HStack(spacing: 12) {
                    HStack {
                        TextField("Mesajınızı yazın...", text: $messageText)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        Image(systemName: "paperclip")
                            .foregroundColor(.white.opacity(0.4))
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
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(AppColors.primary)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            } else {
                Spacer().frame(height: 200)
                Text("Çok yakında...")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .background(Color.white.opacity(0.02))
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
    
    private var bottomActionBar: some View {
        HStack {
            bottomBarButton(
                icon: viewModel.agoraManager.isMuted ? "mic.slash.fill" : "mic.fill",
                label: "Mikrofon",
                active: !viewModel.agoraManager.isMuted
            ) {
                viewModel.toggleMute()
            }
            
            bottomBarButton(
                icon: viewModel.agoraManager.isCameraOn ? "video.fill" : "video.slash.fill",
                label: "Kamera",
                active: viewModel.agoraManager.isCameraOn
            ) {
                viewModel.toggleCamera()
            }
            
            // Main Söz İste
            Button(action: {
                withAnimation { isFloorRequested.toggle() }
                viewModel.requestFloor()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isFloorRequested ? .green : .purple)
                        .frame(width: 56, height: 56)
                        .background((isFloorRequested ? Color.green : Color.purple).opacity(0.1))
                        .clipShape(Circle())
                        .overlay(Circle().stroke((isFloorRequested ? Color.green : Color.purple).opacity(0.3), lineWidth: 1))
                    Text("Söz İste")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isFloorRequested ? .green : .purple)
                }
            }
            .frame(maxWidth: .infinity)
            
            bottomBarButton(icon: "face.smiling", label: "Tepki", active: false) {
                // Tepki logic
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(AppColors.background)
    }
    
    // MARK: - Helper Views
    
    private func participantAvatar(name: String, role: String, roleColor: Color, isMuted: Bool, angle: Double, isSpeaking: Bool = false, isMe: Bool = false) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(isSpeaking ? Color.purple : (isMe ? Color.green : Color.clear), lineWidth: 2)
                    )
                
                if isSpeaking {
                    Circle()
                        .stroke(Color.purple.opacity(0.5), lineWidth: 4)
                        .scaleEffect(1.2)
                }
                
                // Mic Status
                ZStack {
                    Circle()
                        .fill(isMuted ? Color.gray : Color.purple)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                    Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
                .offset(x: 18, y: 18)
            }
            
            VStack(spacing: 0) {
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isMe ? .green : .white)
                Text(role)
                    .font(.system(size: 8))
                    .foregroundColor(roleColor)
            }
        }
        .offset(x: 110 * cos(angle * .pi / 180), y: 110 * sin(angle * .pi / 180))
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? .purple : .gray)
                
                Rectangle()
                    .fill(selectedTab == index ? Color.purple : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func chatRow(name: String, role: String, color: Color, message: String, time: String) -> some View {
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
                        .foregroundColor(color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.1))
                        .cornerRadius(4)
                    Spacer()
                    Text(time)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private func bottomBarButton(icon: String, label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(active ? .purple : .white)
                    .frame(width: 44, height: 44)
                    .background(active ? Color.purple.opacity(0.1) : Color.white.opacity(0.05))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(active ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1))
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(active ? .purple : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}