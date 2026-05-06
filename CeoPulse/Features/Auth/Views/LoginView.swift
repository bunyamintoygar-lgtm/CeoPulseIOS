import SwiftUI
import Supabase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                // Bottom Mesh/Wave Pattern Placeholder
                VStack {
                    Spacer()
                    Image(systemName: "waveform")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .foregroundColor(Color.purple.opacity(0.2))
                        .blur(radius: 20)
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo Section
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                Text("CEO")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Pulse")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(hex: "8A56FF"))
                                    .overlay(
                                        Circle()
                                            .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [2, 4]))
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(Color.purple.opacity(0.5))
                                            .offset(x: 10)
                                    )
                            }
                            .padding(.top, 40)
                            
                            Text("Tek platform.\nSınırsız profesyonel fırsatlar.")
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            
                            Text("Giriş yaparak fırsatları keşfetmeye başlayın.")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // Form Section
                        VStack(alignment: .leading, spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("E-posta adresiniz")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(AppColors.textSecondary)
                                    TextField("ornek@email.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifreniz")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(AppColors.textSecondary)
                                    if isPasswordVisible {
                                        TextField("Şifrenizi giriniz", text: $password)
                                    } else {
                                        SecureField("Şifrenizi giriniz", text: $password)
                                    }
                                    Button(action: { isPasswordVisible.toggle() }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Şifremi Unuttum?")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.purple)
                                }
                            }
                            
                            // Login Button
                            Button(action: signIn) {
                                HStack {
                                    if isLoading {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Giriş Yap")
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
                            .disabled(isLoading)
                        }
                        .padding(.horizontal, 24)
                        
                        // Social Login
                        VStack(spacing: 16) {
                            HStack {
                                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                                Text("veya").font(.system(size: 12)).foregroundColor(AppColors.textSecondary).padding(.horizontal, 8)
                                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                            }
                            .padding(.horizontal, 24)
                            
                            SocialLoginButton(icon: "linkedin_logo", title: "LinkedIn ile Giriş Yap", color: .white)
                            SocialLoginButton(icon: "google_logo", title: "Google ile Giriş Yap", color: .white)
                            SocialLoginButton(icon: "apple_logo", title: "Apple ile Giriş Yap", color: .white)
                        }
                        .padding(.horizontal, 24)
                        
                        // Footer
                        VStack(spacing: 8) {
                            Text("Hesabınız yok mu?")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            NavigationLink(destination: SignUpFlowView()) {
                                Text("Hesap Oluşturun")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.purple)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func signIn() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
                // Success - will be handled by auth state listener in App
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct SocialLoginButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                // Placeholder for social icons
                Image(systemName: icon == "linkedin_logo" ? "link" : (icon == "google_logo" ? "g.circle.fill" : "applelogo"))
                    .font(.system(size: 20))
                    .foregroundColor(icon == "linkedin_logo" ? .blue : (icon == "google_logo" ? .red : .white))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
