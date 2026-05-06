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
    @State var otpCode = ["", "", "", "", "", ""]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        if currentStep > 1 && currentStep < 4 {
                            currentStep -= 1
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
                
                // Progress Bar
                SignUpStepper(currentStep: currentStep)
                    .padding(.top, 20)
                
                // Title Section
                VStack(spacing: 8) {
                    Text("Hesap Oluşturun")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Liderlerle bağlantı kurun, görüşlerinizi paylaşın\nve iş dünyasının nabzını tutun.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // Step Content
                ZStack {
                    if currentStep == 1 {
                        SignUpStep1View(currentStep: $currentStep, firstName: $firstName, lastName: $lastName, email: $email, password: $password, confirmPassword: $confirmPassword, acceptTerms: $acceptTerms)
                    } else if currentStep == 2 {
                        SignUpStep2View(currentStep: $currentStep, position: $position, company: $company, companySize: $companySize, duration: $duration, sector: $sector, skills: $skills, bio: $bio, isPublicProfile: $isPublicProfile)
                    } else if currentStep == 3 {
                        SignUpStep3View(currentStep: $currentStep, email: email, otpCode: $otpCode)
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
    let steps = ["Hesap Bilgileri", "Profesyonel Bilgiler", "Doğrulama", "Tamamla"]
    
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

// Placeholder for Step 1
struct SignUpStep1View: View {
    @Binding var currentStep: Int
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var acceptTerms: Bool
    
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
                        Text("Şifreniz en az 8 karakter olmalı ve aşağıdakileri içermelidir:")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        RequirementRow(text: "Büyük harf (A-Z)", isMet: password.contains(where: { $0.isUppercase }))
                        RequirementRow(text: "Küçük harf (a-z)", isMet: password.contains(where: { $0.isLowercase }))
                        RequirementRow(text: "Rakam (0-9)", isMet: password.contains(where: { $0.isNumber }))
                        RequirementRow(text: "Özel karakter (!@#$%^&*)", isMet: password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*")) != nil)
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
                
                Button(action: { withAnimation { currentStep = 2 } }) {
                    HStack {
                        Text("Devam Et")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "6C38FF"))
                    .cornerRadius(12)
                }
                .padding(.top, 10)
                
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

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(isMet ? .green : AppColors.textSecondary.opacity(0.3))
            Text(text)
                .font(.system(size: 10))
                .foregroundColor(isMet ? .white : AppColors.textSecondary)
        }
    }
}

struct CustomAuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
            
            if isSecure {
                Image(systemName: "eye.slash")
                    .foregroundColor(AppColors.textSecondary)
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

// Step 2, 3, 4 and other components will follow in separate actions or continued here...
