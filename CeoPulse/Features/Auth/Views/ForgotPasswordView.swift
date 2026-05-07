import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var currentStep = 1 // 1: Email, 2: OTP, 3: New Password
    @State private var otpCode = Array(repeating: "", count: 8)
    @FocusState private var activeOTPField: Int?
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    // Password validation computed properties
    private var isPasswordLongEnough: Bool { newPassword.count >= 8 }
    private var hasUppercase: Bool { newPassword.contains(where: { $0.isUppercase }) }
    private var hasLowercase: Bool { newPassword.contains(where: { $0.isLowercase }) }
    private var hasDigit: Bool { newPassword.contains(where: { $0.isNumber }) }
    private var passwordsMatch: Bool { !newPassword.isEmpty && newPassword == confirmPassword }
    private var isPasswordValid: Bool { isPasswordLongEnough && hasUppercase && hasLowercase && hasDigit && passwordsMatch }
    
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
                Text("login_email_label".localized())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(AppColors.textSecondary)
                    TextField("", text: $email, prompt: Text("login_email_placeholder".localized()).foregroundColor(AppColors.textSecondary))
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
                        Text("forgot_pw_button_send".localized())
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
                // 8 haneli OTP
                HStack(spacing: 6) {
                    ForEach(0..<8, id: \.self) { index in
                        TextField("", text: $otpCode[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 52)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(activeOTPField == index ? Color.purple : Color.white.opacity(0.1), lineWidth: 1.5))
                            .focused($activeOTPField, equals: index)
                            .onChange(of: otpCode[index]) { newValue in
                                if newValue.count > 1 { otpCode[index] = String(newValue.last!) }
                                if !newValue.isEmpty && index < 7 { activeOTPField = index + 1 }
                                if newValue.isEmpty && index > 0 { activeOTPField = index - 1 }
                            }
                    }
                }
                
                Button(action: sendRecoveryEmail) {
                    Text("forgot_pw_button_resend".localized())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purple)
                }
            }
            
            Button(action: verifyRecoveryOTP) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("forgot_pw_button_verify".localized())
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(otpCode.joined().count == 8 ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(isLoading || otpCode.joined().count < 8)
        }
        .padding(.horizontal, 24)
    }
    
    private var newPasswordStepView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                CustomAuthField(icon: "lock", placeholder: "forgot_pw_new_pw_placeholder".localized(), text: $newPassword, isSecure: true)
                CustomAuthField(icon: "lock.fill", placeholder: "forgot_pw_confirm_pw_placeholder".localized(), text: $confirmPassword, isSecure: true)
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
                    RequirementRow(text: "pw_req_upper".localized(), isMet: hasUppercase)
                    RequirementRow(text: "pw_req_lower".localized(), isMet: hasLowercase)
                    RequirementRow(text: "pw_req_digit".localized(), isMet: hasDigit)
                    RequirementRow(text: "pw_req_length".localized(), isMet: isPasswordLongEnough) 
                    // Note: Simplified length text, or we could add a dedicated key "Min 8 chars"
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
            
            Button(action: updatePassword) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("forgot_pw_button_update".localized())
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "lock.rotation")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isPasswordValid ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(isLoading || !isPasswordValid)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Computed Properties
    
    private var titleForStep: String {
        switch currentStep {
        case 1: return "forgot_pw_title_step1".localized()
        case 2: return "forgot_pw_title_step2".localized()
        case 3: return "forgot_pw_title_step3".localized()
        default: return ""
        }
    }
    
    private var descriptionForStep: String {
        switch currentStep {
        case 1: return "forgot_pw_desc_step1".localized()
        case 2: return "forgot_pw_desc_step2".localized(with: [email])
        case 3: return "forgot_pw_desc_step3".localized()
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
                    successMessage = "forgot_pw_success_sent".localized()
                }
            } catch {
                let errorString = error.localizedDescription
                if errorString.contains("Failed to reach hook") {
                    await MainActor.run {
                        withAnimation { currentStep = 2 }
                        successMessage = "forgot_pw_success_sent".localized()
                    }
                } else {
                    await MainActor.run { 
                        if errorString.contains("User not found") {
                            errorMessage = "forgot_pw_error_not_found".localized()
                        } else if errorString.contains("rate limit") {
                            errorMessage = "forgot_pw_error_rate_limit".localized()
                        } else {
                            errorMessage = "forgot_pw_error_generic".localized()
                        }
                    }
                }
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
                await MainActor.run { errorMessage = "forgot_pw_error_invalid_code".localized() }
            }
            await MainActor.run { isLoading = false }
        }
    }
    
    func updatePassword() {
        isLoading = true
        errorMessage = nil
        
        let attributes = UserAttributes(password: newPassword)
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.update(user: attributes)
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run { errorMessage = "forgot_pw_error_generic".localized() }
            }
            await MainActor.run { isLoading = false }
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
                .foregroundColor(isMet ? .green : Color.white.opacity(0.2))
            Text(text)
                .font(.system(size: 10))
                .foregroundColor(isMet ? .white : Color.white.opacity(0.5))
        }
    }
}
