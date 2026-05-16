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
                    
                    // Central Control Center (PTT)
                    pttControlCenter
                    
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
    
    private var pttControlCenter: some View {
        HStack(spacing: 20) {
            // Söz İste
            VStack(spacing: 8) {
                Button(action: { viewModel.requestFloor() }) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                Text("Söz İste")
                    .font(.system(size: 12, weight: .bold))
                Text("Sıraya girmek için tıkla")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Bas-Konuş
            VStack(spacing: 12) {
                ZStack {
                    // Outer rings for animation
                    Circle()
                        .stroke(Color.purple.opacity(0.2), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(isPTTPressing ? 1.1 : 1.0)
                    
                    Circle()
                        .fill(
                            RadialGradient(colors: [Color.purple.opacity(0.3), Color.clear], center: .center, startRadius: 0, endRadius: 90)
                        )
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "2A2A40"), Color(hex: "1A1A2E")], startPoint: .top, endPoint: .bottom))
                        .frame(width: 140, height: 140)
                        .shadow(color: .purple.opacity(0.5), radius: 20)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        Text("Bas - Konuş")
                            .font(.system(size: 14, weight: .bold))
                        Text("Konuşmak için basılı tutun")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .onLongPressGesture(minimumDuration: 0, pressing: { isPressing in
                    withAnimation(.spring()) {
                        isPTTPressing = isPressing
                    }
                    viewModel.handlePTT(isPressing: isPressing)
                }, perform: {})
            }
            
            // Sadece Dinle
            VStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "headphones")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                Text("Sadece Dinle")
                    .font(.system(size: 12, weight: .bold))
                Text("Mikrofonu kapat")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 20)
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
            HStack(spacing: 24) {
                tabButton(title: "Sohbet", index: 0)
                tabButton(title: "İçgörüler", index: 1)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Divider().background(Color.white.opacity(0.1))
            
            if selectedTab == 0 {
                VStack(spacing: 16) {
                    // Mini Chat List
                    ForEach(viewModel.messages.prefix(3)) { message in
                        HStack(spacing: 12) {
                            Circle().fill(Color.gray).frame(width: 32, height: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(message.userName ?? "Kullanıcı").font(.system(size: 12, weight: .bold))
                                Text(message.content).font(.system(size: 12)).foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }
    
    private var bottomActionBar: some View {
        HStack(spacing: 40) {
            actionButton(icon: "mic.slash.fill", label: "Mikrofon", sub: "Kapalı", color: .red)
            actionButton(icon: "video.slash.fill", label: "Kamera", sub: "Kapalı", color: .red)
            actionButton(icon: "face.smiling", label: "Tepki Gönder", sub: "", color: .white)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "0A0A0F"))
    }
    
    // MARK: - Helpers
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? .white : .gray)
                Rectangle()
                    .fill(selectedTab == index ? Color.purple : Color.clear)
                    .frame(height: 2)
            }
        }
    }
    
    private func actionButton(icon: String, label: String, sub: String, color: Color) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                if !sub.isEmpty {
                    Text(sub)
                        .font(.system(size: 9))
                        .foregroundColor(color.opacity(0.8))
                }
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