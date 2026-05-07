import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var currentStep = 1 // 1: Email, 2: OTP, 3: New Password
    @State private var otpCode = Array(repeating: "", count: 6)
    @FocusState private var activeOTPField: Int?
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header / Navigation
                HStack {
                    Button(action: {
                        if currentStep > 1 {
                            withAnimation { currentStep -= 1 }
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
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
                        // Header Section
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                Text("CEO")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Pulse")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(hex: "8A56FF"))
                            }
                            
                            Text(titleForStep)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(descriptionForStep)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        // Main Content
                        if currentStep == 1 {
                            emailStepView
                        } else if currentStep == 2 {
                            otpStepView
                        } else {
                            newPasswordStepView
                        }
                        
                        // Messages
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }
                        
                        if let success = successMessage {
                            Text(success)
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                                .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Step Views
    
    private var emailStepView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .frame(width: 180, height: 180)
                    .foregroundColor(Color.purple.opacity(0.3))
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "8A56FF"))
                    .shadow(color: Color(hex: "8A56FF").opacity(0.5), radius: 20)
            }
            .padding(.vertical, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("E-posta adresiniz")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(AppColors.textSecondary)
                    TextField("", text: $email, prompt: Text("ornek@email.com").foregroundColor(Color.white.opacity(0.7)))
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            
            Button(action: sendRecoveryEmail) {
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
    }
    
    private var otpStepView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                // 6 haneli OTP - Supabase varsayılanı
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $otpCode[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 56)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(activeOTPField == index ? Color.purple : Color.white.opacity(0.1), lineWidth: 1.5))
                            .focused($activeOTPField, equals: index)
                            .onChange(of: otpCode[index]) { newValue in
                                if newValue.count > 1 { otpCode[index] = String(newValue.last!) }
                                if !newValue.isEmpty && index < 5 { activeOTPField = index + 1 }
                                if newValue.isEmpty && index > 0 { activeOTPField = index - 1 }
                            }
                    }
                }
                
                Button(action: sendRecoveryEmail) {
                    Text("Kodu Yeniden Gönder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purple)
                }
            }
            
            Button(action: verifyRecoveryOTP) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Kodu Doğrula")
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(otpCode.joined().count == 6 ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(isLoading || otpCode.joined().count < 6)
        }
        .padding(.horizontal, 24)
    }
    
    private var newPasswordStepView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                CustomAuthField(icon: "lock", placeholder: "Yeni Şifre", text: $newPassword, isSecure: true)
                CustomAuthField(icon: "lock.fill", placeholder: "Şifreyi Onayla", text: $confirmPassword, isSecure: true)
            }
            
            Button(action: updatePassword) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Şifreyi Güncelle")
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "lock.rotation")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(newPassword.count >= 6 && newPassword == confirmPassword ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(isLoading || newPassword.count < 6 || newPassword != confirmPassword)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Computed Properties
    
    private var titleForStep: String {
        switch currentStep {
        case 1: return "Şifremi Unuttum"
        case 2: return "Kodu Doğrula"
        case 3: return "Yeni Şifre"
        default: return ""
        }
    }
    
    private var descriptionForStep: String {
        switch currentStep {
        case 1: return "E-posta adresinizi girin, size 6 haneli bir kurtarma kodu gönderelim."
        case 2: return "\(email) adresine gönderilen 6 haneli kodu aşağıya girin."
        case 3: return "Hesabınız için yeni ve güvenli bir şifre belirleyin."
        default: return ""
        }
    }
    
    // MARK: - Logic
    
    func sendRecoveryEmail() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.resetPasswordForEmail(email)
                await MainActor.run {
                    withAnimation { currentStep = 2 }
                    successMessage = "Doğrulama kodu e-posta adresinize gönderildi."
                }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription }
            }
            await MainActor.run { isLoading = false }
        }
    }
    
    func verifyRecoveryOTP() {
        isLoading = true
        errorMessage = nil
        let token = otpCode.joined()
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.verifyOTP(
                    email: email,
                    token: token,
                    type: .recovery
                )
                await MainActor.run {
                    withAnimation { currentStep = 3 }
                }
            } catch {
                await MainActor.run { errorMessage = "Hatalı veya süresi dolmuş kod. Lütfen tekrar deneyin." }
            }
            await MainActor.run { isLoading = false }
        }
    }
    
    func updatePassword() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let attributes = UserAttributes(password: newPassword)
                try await SupabaseManager.shared.client.auth.update(user: attributes)
                await MainActor.run {
                    successMessage = "Şifreniz başarıyla güncellendi!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription }
            }
            await MainActor.run { isLoading = false }
        }
    }
}
