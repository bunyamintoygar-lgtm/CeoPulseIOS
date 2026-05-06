import SwiftUI

struct ProfilePhotoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 1 // 1: Upload, 2: Verification, 3: Success
    @State private var selectedImage: Image? = nil
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Stepper
                SignUpStepper(currentStep: 2) // We reuse the stepper but highlight step 2
                    .padding(.top, 20)
                
                ScrollView {
                    if currentStep == 1 {
                        PhotoUploadStep(currentStep: $currentStep)
                    } else if currentStep == 2 {
                        PhotoVerificationStep(currentStep: $currentStep)
                    } else {
                        PhotoSuccessStep(presentationMode: presentationMode)
                    }
                }
            }
        }
    }
}

// MARK: - Step 1: Upload
struct PhotoUploadStep: View {
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Profil Fotoğrafı")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Profesyonel bir profil fotoğrafı, güven oluşturur\nve daha güçlü bağlantılar kurmanıza yardımcı olur.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Avatar Placeholder
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .frame(width: 200, height: 200)
                    .foregroundColor(Color.purple.opacity(0.3))
                
                Circle()
                    .fill(LinearGradient(colors: [Color.purple.opacity(0.2), Color.purple.opacity(0.4)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 180, height: 180)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                Circle()
                    .fill(Color(hex: "6C38FF"))
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: "plus").foregroundColor(.white).font(.system(size: 20, weight: .bold)))
                    .offset(x: -10, y: -10)
            }
            
            Button(action: { withAnimation { currentStep = 2 } }) {
                HStack {
                    Image(systemName: "arrow.up.doc")
                    Text("Fotoğraf Yükle")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "6C38FF"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            // Tips Grid
            VStack(alignment: .leading, spacing: 16) {
                Text("İyi bir profil fotoğrafı için ipuçları")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    TipIconView(icon: "person.crop.circle.badge.checkmark", label: "Yüzünüz net\nve odakta olsun")
                    TipIconView(icon: "sun.max.fill", label: "İyi aydınlatılmış\nbir ortam seçin")
                    TipIconView(icon: "tshirt.fill", label: "Profesyonel\nkıyafet tercih edin")
                    TipIconView(icon: "face.smiling.fill", label: "Doğal bir ifade\nkullanın")
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.03))
            .cornerRadius(20)
            
            // Examples
            VStack(alignment: .leading, spacing: 16) {
                Text("Örnek profil fotoğrafları")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    PhotoExampleView(imageName: "example1", isGood: true, label: "Doğru")
                    PhotoExampleView(imageName: "example2", isGood: true, label: "Doğru")
                    PhotoExampleView(imageName: "example3", isGood: false, label: "Koyu")
                    PhotoExampleView(imageName: "example4", isGood: false, label: "Uygun değil")
                }
            }
            
            HStack {
                Image(systemName: "info.circle").foregroundColor(.purple)
                Text("JPG, PNG formatları desteklenir. Maks. 5MB boyut.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
            
            Button(action: {}) {
                HStack {
                    Text("Devam Et")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Step 2: Verification
struct PhotoVerificationStep: View {
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Profil Fotoğrafı Doğrulama")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Güvenliğiniz ve topluluk kalitesini korumak için\nprofil fotoğrafınızı doğrulamanız gerekiyor.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Photo with Verification Badge
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 180)
                    .overlay(Text("Fotoğraf Buraya").font(.system(size: 12)))
                
                Circle()
                    .fill(Color(hex: "6C38FF"))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "shield.checkered").foregroundColor(.white))
                    .offset(x: -5, y: -5)
            }
            
            // Checklist
            VStack(alignment: .leading, spacing: 12) {
                Text("Fotoğrafınız doğrulama gereksinimlerini karşılıyor mu?")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                VerificationRow(icon: "person", text: "Yüzünüz net ve görünür olmalı", isMet: true)
                VerificationRow(icon: "sun.max", text: "İyi aydınlatılmış bir ortamda çekilmeli", isMet: true)
                VerificationRow(icon: "person.fill", text: "Sadece siz olmalısınız (tek başınıza)", isMet: true)
                VerificationRow(icon: "tshirt", text: "Profesyonel bir görünüm tercih edilmeli", isMet: true)
                VerificationRow(icon: "face.smiling", text: "Doğal bir ifade kullanılmalı", isMet: true)
                VerificationRow(icon: "nose.fill", text: "Filtre, şapka, güneş gözlüğü kullanılmamalı", isMet: false)
            }
            .padding(20)
            .background(Color.white.opacity(0.03))
            .cornerRadius(20)
            
            Button(action: { withAnimation { currentStep = 3 } }) {
                HStack {
                    Image(systemName: "camera")
                    Text("Yeni Fotoğraf Çek")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "6C38FF"))
                .cornerRadius(12)
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "photo")
                    Text("Galeriden Seç")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "questionmark.circle")
                    Text("Neden doğrulama istiyoruz?")
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Step 3: Success
struct PhotoSuccessStep: View {
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Profil Fotoğrafınızı Tamamlayın")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Profesyonel görünümünüz, güven oluşturur.\nEn iyi sonucu almak için ipuçlarımızı takip edin.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            ZStack(alignment: .bottom) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 180)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Harika! Fotoğrafınız doğrulandı.")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .offset(y: 20)
            }
            .padding(.bottom, 20)
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack {
                    Text("Fotoğrafımı Tamamla")
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
struct TipIconView: View {
    let icon: String
    let label: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.05))
                .clipShape(Circle())
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PhotoExampleView: View {
    let imageName: String
    let isGood: Bool
    let label: String
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 80)
                
                Image(systemName: isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isGood ? .green : .red)
                    .background(Color.white.clipShape(Circle()))
                    .offset(x: 5, y: 5)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct VerificationRow: View {
    let icon: String
    let text: String
    let isMet: Bool
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isMet ? .green : .red)
        }
    }
}
