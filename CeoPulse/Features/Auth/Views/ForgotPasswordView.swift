import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var isSuccess = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header / Navigation
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo Section
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                Text("CEO")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Pulse")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(hex: "8A56FF"))
                            }
                            
                            Text("Şifrenizi mi unuttunuz?")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Endişelenmeyin! Kayıtlı e-posta adresinizi girin, şifrenizi sıfırlamak için size bir bağlantı gönderelim.")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        // Illustration Section (Lock and Orbitals)
                        ZStack {
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .frame(width: 180, height: 180)
                                .foregroundColor(Color.purple.opacity(0.3))
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "8A56FF"))
                                .shadow(color: Color(hex: "8A56FF").opacity(0.5), radius: 20)
                            
                            // Email Icon Orbit
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.purple)
                                .offset(x: -80, y: -40)
                            
                            // Paperplane Icon Orbit
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.purple)
                                .offset(x: 80, y: 10)
                        }
                        .padding(.vertical, 20)
                        
                        // Form Section
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("E-posta adresiniz")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(AppColors.textSecondary)
                                    TextField("", text: $email, prompt: Text("ornek@email.com").foregroundColor(AppColors.textSecondary))
                                        .foregroundColor(.white)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            
                            // Info Box
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Eğer hesabınıza kayıtlı bir e-posta adresi varsa, size şifre sıfırlama bağlantısı gönderilecektir.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(12)
                            
                            // Action Button
                            Button(action: resetPassword) {
                                HStack {
                                    if isLoading {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Kod Gönder")
                                            .font(.system(size: 16, weight: .bold))
                                        Image(systemName: "arrow.right")
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "6C38FF"))
                                .cornerRadius(12)
                            }
                            .disabled(isLoading || email.isEmpty)
                        }
                        .padding(.horizontal, 24)
                        
                        // Footer
                        VStack(spacing: 24) {
                            HStack {
                                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                                Text("veya").font(.system(size: 12)).foregroundColor(AppColors.textSecondary).padding(.horizontal, 8)
                                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                            }
                            
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                Text("Giriş Ekranına Dön")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            
                            HStack(spacing: 4) {
                                Text("Hala sorun mu yaşıyorsunuz?")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                Button(action: {}) {
                                    Text("Destek Ekibi ile İletişime Geçin")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color.purple)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    func resetPassword() {
        guard !email.isEmpty else { return }
        isLoading = true
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.resetPasswordForEmail(email)
                isSuccess = true
                message = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
            } catch {
                message = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
