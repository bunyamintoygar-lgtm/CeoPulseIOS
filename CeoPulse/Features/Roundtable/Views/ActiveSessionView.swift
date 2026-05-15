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
                Text("24 Mayıs 2025, Cumartesi") // Mock for design
                    .font(.system(size: 11))
            }
            .padding(.trailing, 16)
            
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.white.opacity(0.6))
                Text("20:30 - 22:00 (90 dk)")
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
                    Text("34 / 40 Katılımcı")
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
            
            // The 3D-ish Circular Table
            ZStack {
                // Table Base Glow
                Circle()
                    .fill(RadialGradient(colors: [Color.purple.opacity(0.3), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                    .frame(width: 300, height: 300)
                
                // Table Rim
                Circle()
                    .stroke(LinearGradient(colors: [.purple.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                    .frame(width: 200, height: 200)
                
                // Table Inner
                Circle()
                    .fill(Color(hex: "0F0F1A"))
                    .frame(width: 180, height: 180)
                    .shadow(color: .purple.opacity(0.5), radius: 20)
                
                // Central "Söz İste" Button
                Button(action: { withAnimation { isFloorRequested.toggle() } }) {
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
                
                // Avatars around the table
                // Speakers (Top)
                participantAvatar(name: "Ali Yılmaz", role: "Moderatör", roleColor: .purple, isMuted: false, angle: -90, isSpeaking: true)
                participantAvatar(name: "Zeynep K.", role: "Konuşmacı", roleColor: .purple, isMuted: false, angle: -140)
                participantAvatar(name: "Murat A.", role: "Konuşmacı", roleColor: .purple, isMuted: false, angle: -40)
                
                // Listeners (Bottom)
                participantAvatar(name: "Ayşe T.", role: "Dinleyici", roleColor: .gray, isMuted: true, angle: 20)
                participantAvatar(name: "Deniz Y.", role: "Dinleyici", roleColor: .gray, isMuted: true, angle: 70)
                participantAvatar(name: "Sen", role: "Dinleyici", roleColor: .green, isMuted: true, angle: 90, isMe: true)
                participantAvatar(name: "Mehmet D.", role: "Dinleyici", roleColor: .gray, isMuted: true, angle: 110)
                participantAvatar(name: "Selin A.", role: "Konuşmacı", roleColor: .purple, isMuted: false, angle: 160)
                
                // Extra participants indicator
                VStack(spacing: 2) {
                    Text("+25")
                        .font(.system(size: 14, weight: .bold))
                    Text("Diğer")
                        .font(.system(size: 8))
                }
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
                .offset(x: 90, y: 70)
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
                ForEach(0..<12) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 2))
                }
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Text("+19")
                        .font(.system(size: 10, weight: .bold))
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
            // Tabs
            HStack(spacing: 0) {
                tabButton(title: "Sohbet", index: 0)
                tabButton(title: "İçgörüler", index: 1)
                tabButton(title: "Notlar", index: 2)
                tabButton(title: "Anketler", index: 3)
            }
            .padding(.horizontal, 20)
            
            Divider().background(Color.white.opacity(0.1))
            
            // Chat List
            VStack(spacing: 20) {
                chatRow(name: "Ali Yılmaz", role: "Moderatör", color: .purple, message: "Hoş geldiniz! Harika bir sohbet bizi bekliyor.", time: "20:31")
                chatRow(name: "Zeynep K.", role: "Konuşmacı", color: .purple, message: "Sürdürülebilir büyüme için en kritik önceliğiniz sizce nedir?", time: "20:32")
                chatRow(name: "Mehmet D.", role: "Dinleyici", color: .gray, message: "Teknoloji yatırımlarının etkisi hakkında ne düşünüyorsunuz?", time: "20:33")
            }
            .padding(20)
            
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
                
                Button(action: {}) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white.opacity(0.02))
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
    
    private var bottomActionBar: some View {
        HStack {
            bottomBarButton(icon: "mic.slash.fill", label: "Mikrofon")
            bottomBarButton(icon: "video.slash.fill", label: "Kamera")
            
            // Main Söz İste
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.purple)
                        .frame(width: 56, height: 56)
                        .background(Color.purple.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.purple.opacity(0.3), lineWidth: 1))
                    Text("Söz İste")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.purple)
                }
            }
            .frame(maxWidth: .infinity)
            
            bottomBarButton(icon: "face.smiling", label: "Tepki")
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
    
    private func bottomBarButton(icon: String, label: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Extension for corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}