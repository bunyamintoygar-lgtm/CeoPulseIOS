import SwiftUI
import Supabase

struct SignUpFlowView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 1
    
    // Step 1 Data
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var acceptTerms = false
    
    // Step 2 Data
    @State var position = ""
    @State var company = ""
    @State var companySize = ""
    @State var duration = ""
    @State var sector = ""
    @State var skills: [String] = ["Liderlik", "Dijital Dönüşüm", "Strateji", "Yapay Zeka"]
    @State var bio = ""
    @State var isPublicProfile = true
    
    // Step 3 Data
    @State var otpCode = ["", "", "", "", "", "", "", ""]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header and Stepper removed as per user request
                Spacer().frame(height: 20)
                
                // Title Section
                if currentStep < 4 {
                    VStack(spacing: 8) {
                        Text(currentStep == 2 ? "Doğrulama" : "Hesap Oluşturun")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(currentStep == 2 ? "\(email) adresine gönderilen\n8 haneli kodu aşağıya girin." : "Liderlerle bağlantı kurun, görüşlerinizi paylaşın\nve iş dünyasının nabzını tutun.")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                } else {
                    Spacer().frame(height: 20)
                }
                
                // Step Content
                ZStack {
                    if currentStep == 1 {
                        SignUpStep1View(currentStep: $currentStep, firstName: $firstName, lastName: $lastName, email: $email, password: $password, confirmPassword: $confirmPassword, acceptTerms: $acceptTerms)
                    } else if currentStep == 2 {
                        SignUpStep3View(currentStep: $currentStep, email: email, otpCode: $otpCode)
                    } else if currentStep == 3 {
                        SignUpStep2View(currentStep: $currentStep, position: $position, company: $company, companySize: $companySize, duration: $duration, sector: $sector, skills: $skills, bio: $bio, isPublicProfile: $isPublicProfile)
                    } else {
                        SignUpStep4View()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .navigationBarHidden(true)
    }
}

struct SignUpStepper: View {
    let currentStep: Int
    let steps = ["Hesap Bilgileri", "Doğrulama", "Profesyonel Bilgiler", "Tamamla"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { index in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(index + 1 <= currentStep ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
                            .frame(width: 28, height: 28)
                        
                        if index + 1 < currentStep {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(index + 1 <= currentStep ? .white : AppColors.textSecondary)
                        }
                    }
                    
                    Text(steps[index])
                        .font(.system(size: 9))
                        .foregroundColor(index + 1 <= currentStep ? .white : AppColors.textSecondary)
                        .frame(width: 80)
                        .multilineTextAlignment(.center)
                }
                
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(index + 1 < currentStep ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .offset(y: -14)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct SignUpStep1View: View {
    @Binding var currentStep: Int
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var acceptTerms: Bool
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    func handleSignUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let userData: [String: AnyJSON] = [
                    "first_name": .string(firstName),
                    "last_name": .string(lastName),
                    "lang": .string(LanguageManager.shared.currentLanguage)
                ]
                
                try await SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: password,
                    data: userData
                )
                
                await MainActor.run {
                    withAnimation {
                        currentStep = 2
                    }
                }
            } catch {
                await MainActor.run {
                    let description = error.localizedDescription
                    if description.contains("invalid format") && description.contains("email") {
                        errorMessage = NSLocalizedString("error_invalid_email", comment: "Geçersiz e-posta adresi")
                    } else if description.contains("already registered") {
                        errorMessage = NSLocalizedString("error_user_exists", comment: "Bu e-posta adresi zaten kullanımda")
                    } else if description.contains("Password") && description.contains("short") {
                        errorMessage = NSLocalizedString("error_password_short", comment: "Şifre en az 6 karakter olmalıdır")
                    } else {
                        errorMessage = description
                    }
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hesap Bilgileri")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Başlamak için temel bilgilerinizi girin.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                
                Group {
                    CustomAuthField(icon: "person", placeholder: "Adınız", text: $firstName)
                    CustomAuthField(icon: "person", placeholder: "Soyadınız", text: $lastName)
                    CustomAuthField(icon: "envelope", placeholder: "E-posta adresiniz", text: $email)
                    CustomAuthField(icon: "lock", placeholder: "Şifre Oluşturun", text: $password, isSecure: true)
                    CustomAuthField(icon: "lock", placeholder: "Şifrenizi Tekrar Girin", text: $confirmPassword, isSecure: true)
                }
                
                // Password Requirements
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.purple)
                        Text("pw_req_title".localized())
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        RequirementRow(text: "pw_req_upper".localized(), isMet: password.contains(where: { $0.isUppercase }))
                        RequirementRow(text: "pw_req_lower".localized(), isMet: password.contains(where: { $0.isLowercase }))
                        RequirementRow(text: "pw_req_digit".localized(), isMet: password.contains(where: { $0.isNumber }))
                        RequirementRow(text: "pw_req_length".localized(), isMet: password.count >= 8)
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                
                Toggle(isOn: $acceptTerms) {
                    Text("Kullanım Koşulları ve Gizlilik Politikası’nı okudum ve kabul ediyorum.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .toggleStyle(CheckboxToggleStyle())
                
                Button(action: handleSignUp) {
                    HStack {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Devam Et")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "6C38FF"))
                    .cornerRadius(12)
                }
                .disabled(isLoading || !acceptTerms || firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty)
                .padding(.top, 10)
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                
                // Social Section
                VStack(spacing: 16) {
                    HStack {
                        Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                        Text("veya").font(.system(size: 12)).foregroundColor(AppColors.textSecondary).padding(.horizontal, 8)
                        Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    }
                    
                    SocialLoginButton(icon: "linkedin", title: "LinkedIn ile Kayıt Ol", color: .white)
                    SocialLoginButton(icon: "google", title: "Google ile Kayıt Ol", color: .white)
                    SocialLoginButton(icon: "apple", title: "Apple ile Kayıt Ol", color: .white)
                }
                
                HStack {
                    Spacer()
                    Text("Zaten bir hesabınız var mı?")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                    Button(action: {}) {
                        Text("Giriş Yapın")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.purple)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
    }
}


// MARK: - Shared Auth Components

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(isMet ? .green : Color.white.opacity(0.2))
            Text(text)
                .font(.system(size: 10))
                .foregroundColor(isMet ? .white : Color.white.opacity(0.5))
        }
    }
}

struct CustomAuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var isVisible: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 20)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 16))
                }
                
                if isSecure && !isVisible {
                    SecureField("", text: $text)
                        .foregroundColor(.white)
                } else {
                    TextField("", text: $text)
                        .foregroundColor(.white)
                }
            }
            
            if isSecure {
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye" : "eye.slash")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .purple : AppColors.textSecondary)
                .font(.system(size: 20))
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

struct SingleOTPInput: View {
    let index: Int
    @Binding var otpCode: [String]
    @FocusState.Binding var activeField: Int?
    
    var body: some View {
        TextField("", text: $otpCode[index])
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 38, height: 52)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(activeField == index ? Color.purple : Color.white.opacity(0.1), lineWidth: 1)
            )
            .focused($activeField, equals: index)
            .onChange(of: otpCode[index]) { (newValue: String) in
                if newValue.count > 1 {
                    otpCode[index] = String(newValue.suffix(1))
                }
                if !newValue.isEmpty && index < 7 {
                    activeField = index + 1
                } else if newValue.isEmpty && index > 0 {
                    activeField = index - 1
                }
            }
    }
}
