import SwiftUI
import PhotosUI

struct ProfilePhotoFlowView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentSubStep = 1
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        if currentSubStep == 1 {
                            step1InitialUpload
                        } else if currentSubStep == 2 {
                            step2Verification
                        } else if currentSubStep == 3 {
                            step3Confirmation
                        } else {
                            step4Success
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                // Footer Action
                footerActionView
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(image: $selectedImage, sourceType: pickerSource)
                .onDisappear {
                    if selectedImage != nil {
                        withAnimation { currentSubStep = 2 }
                    }
                }
        }
    }
    
    // ... rest of the views (I will update the buttons in step2Verification)
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: {
                if currentSubStep > 1 {
                    currentSubStep -= 1
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(NSLocalizedString("photo_title", comment: ""))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var footerActionView: some View {
        VStack(spacing: 12) {
            if currentSubStep == 4 {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    HStack {
                        Text(NSLocalizedString("button_continue", comment: ""))
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "6C38FF"))
                    .cornerRadius(12)
                }
            } else if currentSubStep != 2 {
                Button(action: {
                    withAnimation {
                        if currentSubStep < 4 { currentSubStep += 1 }
                    }
                }) {
                    HStack {
                        Text(currentSubStep == 3 ? NSLocalizedString("button_complete", comment: "") : NSLocalizedString("button_continue", comment: ""))
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "6C38FF"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(AppColors.background)
    }
    
    // MARK: - Step 1: Initial Upload
    private var step1InitialUpload: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(NSLocalizedString("photo_title", comment: ""))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(NSLocalizedString("photo_subtitle", comment: ""))
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Upload Placeholder
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(Color.purple.opacity(0.5))
                    .frame(width: 180, height: 180)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 170, height: 170)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.2))
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.purple)
                            .background(Circle().fill(.white))
                            .offset(x: -10, y: -10)
                    }
                }
                .frame(width: 180, height: 180)
            }
            .onTapGesture { 
                pickerSource = .photoLibrary
                isPickerPresented = true 
            }
            
            Button(action: { 
                pickerSource = .photoLibrary
                isPickerPresented = true 
            }) {
                HStack {
                    Image(systemName: "arrow.up.circle")
                    Text(NSLocalizedString("photo_upload_button", comment: ""))
                }
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "6C38FF"))
                .cornerRadius(10)
                .foregroundColor(.white)
            }
            
            Text(NSLocalizedString("photo_drag_drop", comment: ""))
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            
            // Tips (Mock translation for now as they are very specific)
            VStack(alignment: .leading, spacing: 16) {
                Text("Tips for a great profile photo")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 12) {
                    TipItem(icon: "person.crop.circle.badge.checkmark", text: "Face in focus")
                    TipItem(icon: "sun.max", text: "Good lighting")
                    TipItem(icon: "tshirt", text: "Professional look")
                    TipItem(icon: "face.smiling", text: "Natural expression")
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
    
    // MARK: - Step 2: Verification
    private var step2Verification: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(NSLocalizedString("photo_verification_title", comment: ""))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(NSLocalizedString("photo_subtitle", comment: ""))
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Selected Image
            ZStack(alignment: .bottomTrailing) {
                if let uiImage = selectedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.purple, lineWidth: 3))
                }
                
                Image(systemName: "shield.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.purple))
                    .offset(x: -5, y: -5)
            }
            
            // Actions
            VStack(spacing: 12) {
                Button(action: { 
                    pickerSource = .camera
                    isPickerPresented = true 
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text(NSLocalizedString("photo_take_new", comment: ""))
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "6C38FF"))
                    .cornerRadius(12)
                }
                
                Button(action: { 
                    pickerSource = .photoLibrary
                    isPickerPresented = true 
                }) {
                    HStack {
                        Image(systemName: "photo")
                        Text(NSLocalizedString("photo_select_gallery", comment: ""))
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
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
        }
    }
    
    // MARK: - Step 3: Confirmation
    private var step3Confirmation: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Profil Fotoğrafınızı Tamamlayın")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Profesyonel görünümünüz, güven oluşturur. En iyi sonucu almak için ipuçlarımızı takip edin.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Selected Image
            ZStack(alignment: .bottomTrailing) {
                if let uiImage = selectedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.purple.opacity(0.3), lineWidth: 1))
                }
                
                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.purple))
                    .offset(x: -5, y: -5)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Harika! Fotoğrafınız doğrulandı.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.green)
            }
            
            // Tips Recap
            VStack(alignment: .leading, spacing: 16) {
                Text("Daha güçlü bir profil için ipuçları")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    ChecklistItemMini(text: "Yüzünüz net ve odakta olsun", isMet: true)
                    ChecklistItemMini(text: "İyi aydınlatılmış bir ortam seçin", isMet: true)
                    ChecklistItemMini(text: "Profesyonel bir görünüm tercih edin", isMet: true)
                    ChecklistItemMini(text: "Doğal bir ifade kullanın", isMet: true)
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            
            // Examples Mini
            VStack(alignment: .leading, spacing: 12) {
                Text("Örnek fotoğraflar")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    ExamplePhotoMini(imageName: "example1", label: "Doğru", isValid: true)
                    ExamplePhotoMini(imageName: "example2", label: "Doğru", isValid: true)
                    ExamplePhotoMini(imageName: "example3", label: "Doğru", isValid: true)
                    ExamplePhotoMini(imageName: "example4", label: "Koyu", isValid: false)
                    ExamplePhotoMini(imageName: "example5", label: "Uygun değil", isValid: false)
                }
            }
        }
    }
    
    // MARK: - Step 4: Success
    private var step4Success: some View {
        VStack(spacing: 32) {
            ZStack {
                // Confetti Placeholder
                Circle()
                    .fill(RadialGradient(colors: [.purple.opacity(0.2), .clear], center: .center, startRadius: 0, endRadius: 150))
                    .frame(width: 300, height: 300)
                
                if let uiImage = selectedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(
                            ZStack {
                                Circle().stroke(Color.white.opacity(0.1), lineWidth: 4)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                    .background(Circle().fill(.white))
                                    .offset(x: 65, y: 55)
                            }
                        )
                }
            }
            
            VStack(spacing: 12) {
                Text("Profil fotoğrafınız başarıyla\ntamamlandı!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Tebrikler! Profil fotoğrafınız artık aktif.\nProfesyonel profilinizle daha güçlü bağlantılar kurabilirsiniz.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                SuccessBenefitRow(icon: "person.badge.shield.checkmark", title: "Profil fotoğrafınız doğrulandı", subtitle: "Fotoğrafınız topluluk standartlarına uygun.")
                SuccessBenefitRow(icon: "shield.fill", title: "Güvenilirliğiniz arttı", subtitle: "Doğrulanmış profil daha fazla güven sağlar.")
                SuccessBenefitRow(icon: "chart.bar.fill", title: "Daha fazla görünürlük", subtitle: "Profesyonel profiliniz öne çıkmaya hazır.")
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            
            // Next Step Promo
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.purple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sonraki adım önerisi").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    Text("Profilinizi daha da güçlendirmek için yeteneklerinizi ve deneyimlerinizi eklemeyi unutmayın.").font(.system(size: 10)).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Button("Profilimi Güçlendir") {}
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
    }
}

// MARK: - Helper Components

struct TipItem: View {
    let icon: String
    let text: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.purple.opacity(0.1)))
            Text(text)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
}

struct ExamplePhoto: View {
    let imageName: String
    let isValid: Bool
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(12)
            
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
                .background(Circle().fill(.white))
                .padding(6)
        }
    }
}

struct ExamplePhotoMini: View {
    let imageName: String
    let label: String
    let isValid: Bool
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 55, height: 55)
                    .cornerRadius(8)
                
                Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isValid ? .green : .red)
                    .background(Circle().fill(.white))
                    .offset(x: 4, y: 4)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

struct ChecklistItem: View {
    let text: String
    let isMet: Bool
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .foregroundColor(AppColors.textSecondary)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isMet ? .green : .red)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        Divider().background(Color.white.opacity(0.05))
    }
}

struct ChecklistItemMini: View {
    let text: String
    let isMet: Bool
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle")
                .foregroundColor(.purple)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
        }
    }
}

struct SuccessBenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.purple.opacity(0.1)))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green.opacity(0.5))
        }
    }
}

// Custom ImagePicker supporting both camera and gallery
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
