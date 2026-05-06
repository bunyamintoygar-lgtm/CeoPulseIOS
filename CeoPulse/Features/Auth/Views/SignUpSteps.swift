import SwiftUI

// MARK: - Step 2: Profesyonel Bilgiler
struct SignUpStep2View: View {
    @Binding var currentStep: Int
    @Binding var position: String
    @Binding var company: String
    @Binding var companySize: String
    @Binding var duration: String
    @Binding var sector: String
    @Binding var skills: [String]
    @Binding var bio: String
    @Binding var isPublicProfile: Bool
    
    @StateObject private var configManager = ConfigManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profesyonel Bilgiler")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Deneyiminizi ve uzmanlık alanlarınızı paylaşarak size özel bir deneyim sunmamıza yardımcı olun.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                
                // Dropdowns
                VStack(spacing: 12) {
                    CustomDropdown(label: "Pozisyonunuz", selection: $position, options: configManager.positions)
                    CustomAuthField(icon: "building", placeholder: "Şirket adı", text: $company)
                    
                    HStack(spacing: 12) {
                        CustomDropdown(label: "Şirket büyüklüğü", selection: $companySize, options: configManager.companySizes)
                        CustomDropdown(label: "Çalışma süreniz", selection: $duration, options: configManager.durations)
                    }
                    
                    CustomDropdown(label: "Sektör", selection: $sector, options: configManager.sectors)
                }
                .onAppear {
                    Task {
                        await configManager.fetchConfigs()
                    }
                }
                
                // Skills Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(skills, id: \.self) { skill in
                            HStack(spacing: 4) {
                                Text(skill)
                                Image(systemName: "xmark")
                                    .font(.system(size: 10))
                            }
                            .font(.system(size: 12))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.purple.opacity(0.5), lineWidth: 1))
                        }
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Ekle")
                            }
                            .font(.system(size: 12))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                        }
                    }
                }
                
                // Bio
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kısa Biyografi (İsteğe bağlı)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("\(bio.count) / 300")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding(8)
                                }
                            }
                        )
                }
                
                Toggle("Profilimi herkese açık hale getir", isOn: $isPublicProfile)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                
                Button(action: handleProfileUpdate) {
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
...
    @State private var isLoading = false
    
    func handleProfileUpdate() {
        isLoading = true
        
        Task {
            do {
                let currentUser = try await SupabaseManager.shared.client.auth.session.user
                
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .update([
                        "position": .string(position),
                        "company": .string(company),
                        "company_size": .string(companySize),
                        "duration": .string(duration),
                        "sector": .string(sector),
                        "skills": .array(skills.map { .string($0) }),
                        "bio": .string(bio),
                        "is_public": .bool(isPublicProfile)
                    ])
                    .eq("id", value: currentUser.id)
                    .execute()
                
                withAnimation {
                    currentStep = 3
                }
            } catch {
                print("Profile update error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
                
                Button(action: { withAnimation { currentStep = 3 } }) {
                    VStack(spacing: 8) {
                        Text("Atlayın").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                        Text("Bu adımı atla")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Daha sonra profilinizden düzenleyebilirsiniz.")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Step 3: Doğrulama (OTP)
struct SignUpStep3View: View {
    @Binding var currentStep: Int
    let email: String
    @Binding var otpCode: [String]
    @FocusState private var activeField: Int?
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    func handleOTPVerification() {
        isLoading = true
        errorMessage = nil
        
        let token = otpCode.joined()
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.verifyOTP(
                    email: email,
                    token: token,
                    type: .signup
                )
                
                withAnimation {
                    currentStep = 4
                }
            } catch {
                errorMessage = "Hatalı veya süresi dolmuş kod. Lütfen tekrar deneyin."
                print("OTP Error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Doğrulama")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text("Güvenliğiniz bizim için önemli. Lütfen e-posta adresinize gönderilen doğrulama kodunu girin.")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: 24) {
                // Illustration
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 180)
                    
                    VStack(spacing: 12) {
                        ZStack {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.purple.opacity(0.3))
                            Image(systemName: "shield.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .offset(y: 5)
                        }
                        
                        VStack(spacing: 4) {
                            Text("E-postanıza kod gönderdik!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(email) adresine gönderilen\n6 haneli kodu aşağıya girin.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                // OTP Input
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $otpCode[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 50)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(activeField == index ? Color.purple : Color.white.opacity(0.1), lineWidth: 1))
                            .focused($activeField, equals: index)
                            .onChange(of: otpCode[index]) { newValue in
                                if newValue.count > 1 { otpCode[index] = String(newValue.last!) }
                                if !newValue.isEmpty && index < 5 { activeField = index + 1 }
                                if newValue.isEmpty && index > 0 { activeField = index - 1 }
                            }
                    }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                HStack {
                    Image(systemName: "clock")
                    Text("Kodu yeniden gönderme: 01:45")
                }
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
                
                Button(action: handleOTPVerification) {
                    HStack {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Doğrula ve Devam Et")
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
                .disabled(isLoading || otpCode.joined().count < 6)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Step 4: Tamamla
struct SignUpStep4View: View {
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 250)
                
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                        .shadow(color: .purple.opacity(0.5), radius: 20)
                    
                    VStack(spacing: 8) {
                        Text("Tebrikler!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("Hesabınız başarıyla oluşturuldu.")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        HStack(spacing: 4) {
                            Text("CEO Pulse")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.purple)
                            Text("topluluğuna hoş geldiniz.")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Hesabınızı kişiselleştirin")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Daha iyi bir deneyim için aşağıdaki adımları tamamlamanızı öneririz.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                
                VStack(spacing: 12) {
                    PersonalizationRow(icon: "person.fill", title: "Profilinizi tamamlayın", subtitle: "Profil fotoğrafı, hakkında bilgisi...", actionTitle: "Tamamla")
                    PersonalizationRow(icon: "briefcase.fill", title: "İlgi alanlarınızı seçin", subtitle: "Size özel içerik ve etkinlik önerileri...", actionTitle: "Seç")
                    PersonalizationRow(icon: "bell.fill", title: "Bildirim tercihlerinizi ayarlayın", subtitle: "Önemli gelişmelerden haberdar olmak için...", actionTitle: "Ayarla")
                }
            }
            
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading) {
                    Text("Premium'u keşfedin").font(.system(size: 14, weight: .bold))
                    Text("Daha fazla özelliğe erişin, ağınızı büyütün...").font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Button("Keşfet") {}.font(.system(size: 12, weight: .bold)).padding(.horizontal, 16).padding(.vertical, 8).background(Color.white.opacity(0.1)).cornerRadius(8)
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
            
            Button(action: {}) {
                HStack {
                    Text("CEO Pulse'a Başla")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "6C38FF"))
                .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Subcomponents
struct CustomDropdown: View {
    let label: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection = option
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label).font(.system(size: 10)).foregroundColor(AppColors.textSecondary)
                    Text(selection.isEmpty ? "Seçiniz" : selection)
                        .font(.system(size: 14))
                        .foregroundColor(selection.isEmpty ? .white.opacity(0.4) : .white)
                }
                Spacer()
                Image(systemName: "chevron.down").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct PersonalizationRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .padding(10)
                .background(Color.white.opacity(0.05))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Button(actionTitle) {}
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
}
