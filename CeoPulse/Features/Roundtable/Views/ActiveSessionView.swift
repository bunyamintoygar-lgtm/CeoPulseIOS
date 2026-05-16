import SwiftUI
import Combine
import Supabase

struct ActiveSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: ActiveSessionViewModel
    @State private var messageText = ""
    @State private var selectedTab = 0
    @State private var isPTTPressing = false
    
    init(roundtable: Roundtable) {
        _viewModel = StateObject(wrappedValue: ActiveSessionViewModel(roundtable: roundtable))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Event Info Bar
            eventInfoBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Participant Cards Grid
                    participantGrid
                    
                    // Listeners and PTT Control
                    masadakilerSection
                    
                    // Chat & Insights Tabs
                    tabsSection
                }
                .padding(.top, 16)
            }
            
            // Current Speaker Notification Bar
            currentSpeakerBar
            
            // Bottom Action Bar
            bottomActionBar
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.setupSession()
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
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
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var eventInfoBar: some View {
        HStack {
            Label("24 Mayıs 2025, Cumartesi", systemImage: "calendar")
            Spacer()
            Label("20:30 - 22:00 (90 dk)", systemImage: "clock")
            Spacer()
            HStack(spacing: 4) {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text("Canlı")
            }
        }
        .font(.system(size: 11))
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private var participantGrid: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Text("Aktif Konuşmacılar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                
                let speakerCount = min(viewModel.participants.count, 4)
                Text("\(speakerCount) / 4 Konuşmacı")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            // Cards
            HStack(spacing: 8) {
                let stageParticipants = Array(viewModel.participants.prefix(4))
                let emptyCount = max(0, 4 - stageParticipants.count)
                
                ForEach(stageParticipants) { participant in
                    FilledParticipantCard(
                        participant: participant,
                        isSpeaking: participant.userId == viewModel.roundtable.currentSpeakerId
                    )
                }
                
                ForEach(0..<emptyCount, id: \.self) { _ in
                    EmptyParticipantCard()
                }
            }
            .padding(.horizontal, 20)
            
            // Info text below cards
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(.purple)
                Text("15 saniye konuşmayan aktif konuşmacı otomatik olarak yerini sıradakine bırakır.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private var masadakilerSection: some View {
        let stageParticipants = Array(viewModel.participants.prefix(4))
        let listeners = Array(viewModel.participants.dropFirst(4))
        let isUserOnStage = stageParticipants.contains { $0.userId == viewModel.currentUserId }
        let currentParticipant = viewModel.participants.first { $0.userId == viewModel.currentUserId }
        let isRequesting = currentParticipant?.isRequestingFloor ?? false
        let isStageFull = stageParticipants.count >= 4
        
        return VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Masadakiler")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            // Listeners or Empty State
            if listeners.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.purple.opacity(0.7))
                    VStack(spacing: 4) {
                        Text("Henüz masada kimse yok")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Masaya katılan kişiler burada görünecek.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -12) {
                            ForEach(listeners.prefix(8)) { listener in
                                if let avatar = listener.userAvatar, !avatar.isEmpty {
                                    AsyncImage(url: URL(string: avatar)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(hex: "0A0A0F"), lineWidth: 2))
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(listener.userName?.prefix(1).uppercased() ?? "U")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                        .overlay(Circle().stroke(Color(hex: "0A0A0F"), lineWidth: 2))
                                }
                            }
                            if listeners.count > 8 {
                                Circle()
                                    .fill(Color(hex: "1A1A2E"))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("+\(listeners.count - 8)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .overlay(Circle().stroke(Color(hex: "0A0A0F"), lineWidth: 2))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("Tümünü Gör")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.trailing, 20)
                }
            }
            
            // PTT Circle Section
            ZStack {
                if !listeners.isEmpty {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.03))
                        .padding(.horizontal, 20)
                }
                
                VStack {
                    if isUserOnStage {
                        pttCircleButton(
                            title: "Şu an aktif\nkonuşmacısınız",
                            actionText: "Ayrıl",
                            badge: "Aktif Konuşmacı",
                            isActive: true
                        ) {
                            // Leave stage logic
                        }
                    } else if isStageFull {
                        if isRequesting {
                            pttCircleButton(
                                title: "Şu an sıradasınız",
                                actionText: "Vazgeç",
                                badge: "Sıradasınız",
                                isActive: true
                            ) {
                                viewModel.requestFloor() // Cancel request
                            }
                        } else {
                            pttCircleButton(
                                title: "Aktif konuşmacı\nolmak için basın",
                                actionText: "Sıraya Gir",
                                badge: nil,
                                isActive: false
                            ) {
                                viewModel.requestFloor() // Join queue
                            }
                        }
                    } else {
                        pttCircleButton(
                            title: "Aktif konuşmacı\nolmak için basın",
                            actionText: nil,
                            badge: nil,
                            isActive: false
                        ) {
                            viewModel.requestFloor() // Join stage directly
                        }
                    }
                }
                .padding(.vertical, 32)
            }
            
            // Lightning Text
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.white.opacity(0.5))
                Text("Konuştuğunuz an 15 sn. konuşmayan aktif varsa yerine geçersiniz.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
    }
    
    private func pttCircleButton(title: String, actionText: String?, badge: String?, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                // Outer glow
                Circle()
                    .stroke(Color.purple.opacity(isActive ? 0.6 : 0.3), lineWidth: 2)
                    .frame(width: 180, height: 180)
                    .shadow(color: .purple.opacity(isActive ? 0.5 : 0.2), radius: 20)
                    .background(Circle().fill(Color(hex: "0A0A0F"))) // Solid background inside
                
                // Inner gradient for glowing effect
                Circle()
                    .fill(
                        RadialGradient(colors: [Color.purple.opacity(0.3), Color.clear], center: .center, startRadius: 0, endRadius: 90)
                    )
                    .frame(width: 160, height: 160)
                
                // Badge
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "1A1A2E"))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .offset(y: -90)
                }
                
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .font(.system(size: 16))
                            .foregroundColor(isActive ? .purple : .white.opacity(0.5))
                        Image(systemName: "mic.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                        Image(systemName: "waveform")
                            .font(.system(size: 16))
                            .foregroundColor(isActive ? .purple : .white.opacity(0.5))
                    }
                    
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if let actionText = actionText {
                        Text(actionText)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var currentSpeakerBar: some View {
        if let speakerName = viewModel.currentSpeakerName {
            HStack(spacing: 12) {
                // Waveform animation
                HStack(spacing: 3) {
                    ForEach(0..<4) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.purple)
                            .frame(width: 3, height: CGFloat.random(in: 10...20))
                    }
                }
                
                Text("\(speakerName) şu anda konuşuyor")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .shadow(color: .green, radius: 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private var tabsSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 32) {
                tabButton(title: "Sohbet", index: 0)
                tabButton(title: "Notlar", index: 1)
                tabButton(title: "Katılımcılar (\(viewModel.participants.count))", index: 2)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Divider().background(Color.white.opacity(0.1))
            
            if selectedTab == 0 {
                VStack(spacing: 16) {
                    // Chat List
                    if viewModel.messages.isEmpty {
                        // Show mock data for visual parity with design
                        chatMessageRow(
                            name: "Zeynep K.",
                            role: "Konuşmacı",
                            time: "20:32",
                            content: "Sürdürülebilir büyüme için en kritik önceliğiniz sizce nedir?",
                            replies: 0,
                            avatar: nil
                        )
                        chatMessageRow(
                            name: "Murat A.",
                            role: "Konuşmacı",
                            time: "20:33",
                            content: "Teknoloji yatırımlarının etkisi hakkında ne düşünüyorsunuz?",
                            replies: 3,
                            avatar: nil
                        )
                    } else {
                        ForEach(viewModel.messages) { message in
                            chatMessageRow(
                                name: message.userName ?? "Kullanıcı",
                                role: "Katılımcı", // In real app, fetch role from participants
                                time: "Şimdi",
                                content: message.content,
                                replies: 0,
                                avatar: nil
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
    }
    
    private func chatMessageRow(name: String, role: String, time: String, content: String, replies: Int, avatar: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(name.prefix(1).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(role)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.15))
                            .cornerRadius(6)
                        
                        Spacer()
                        
                        Text(time)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Text(content)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                    
                    if replies > 0 {
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Text("\(replies) yanıt")
                                Image(systemName: "chevron.down")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.purple)
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var bottomActionBar: some View {
        if selectedTab == 0 {
            HStack(spacing: 12) {
                // Text Field
                HStack {
                    TextField("Mesajınızı yazın...", text: $messageText)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        Image(systemName: "paperclip")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(24)
                
                // Send Button
                Button(action: {
                    guard !messageText.isEmpty else { return }
                    let textToSend = messageText
                    messageText = ""
                    Task {
                        await viewModel.sendMessage(textToSend)
                    }
                }) {
                    Circle()
                        .fill(Color(hex: "6B4EFF")) // Purple matching the design
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(Color(hex: "0A0A0F"))
        } else {
            Spacer().frame(height: 24)
        }
    }
    
    // MARK: - Helpers
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? Color.purple : .white.opacity(0.7))
                Rectangle()
                    .fill(selectedTab == index ? Color.purple : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

struct FilledParticipantCard: View {
    let participant: RoundtableParticipant
    let isSpeaking: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Moderator Tag
            if participant.role == .moderator {
                Text("Moderatör")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                    .padding(.top, 8)
            } else {
                Spacer().frame(height: 20) // Placeholder
            }
            
            // Avatar with Mic Badge
            ZStack(alignment: .bottomTrailing) {
                if let avatar = participant.userAvatar, !avatar.isEmpty {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(participant.userName?.prefix(1).uppercased() ?? "U")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                
                // Mic Badge
                ZStack {
                    Circle()
                        .fill(Color(hex: "0A0A0F")) // Match background roughly
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(participant.isMuted ? Color.white.opacity(0.1) : Color.green.opacity(0.2))
                        .frame(width: 14, height: 14)
                    Image(systemName: participant.isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 7))
                        .foregroundColor(participant.isMuted ? .white.opacity(0.5) : .green)
                }
                .offset(x: 2, y: 2)
            }
            
            // Info
            VStack(spacing: 2) {
                Text(participant.userName ?? "Kullanıcı")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(participant.role.title)
                    .font(.system(size: 9))
                    .foregroundColor(participant.role == .listener ? .gray : .purple)
            }
            
            Spacer()
            
            // Equalizer
            HStack(spacing: 2) {
                ForEach(0..<8) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isSpeaking ? Color.purple : Color.white.opacity(0.1))
                        .frame(width: 2.5, height: isSpeaking ? CGFloat.random(in: 4...12) : 3)
                }
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct EmptyParticipantCard: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    .frame(width: 48, height: 48)
                Image(systemName: "person")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.top, 20)
            
            VStack(spacing: 2) {
                Text("Henüz aktif")
                Text("konuşmacı yok")
            }
            .font(.system(size: 9))
            .foregroundColor(.white.opacity(0.5))
            .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}