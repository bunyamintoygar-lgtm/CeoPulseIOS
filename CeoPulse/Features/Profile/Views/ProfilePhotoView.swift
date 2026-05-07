import SwiftUI
import PhotosUI
import AVFoundation

struct ProfilePhotoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var supabaseManager: SupabaseManager
    @StateObject private var langManager = LanguageManager.shared
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 12) {
                        Text("photo_title".localized())
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("photo_subtitle".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 40)
                    
                    // Main Photo Frame (Dotted Circle)
                    ZStack {
                        Circle()
                            .stroke(Color.purple.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 4]))
                            .frame(width: 220, height: 220)
                        
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 190, height: 190)
                            .overlay(
                                Group {
                                    if let image = selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 80))
                                            .foregroundColor(.purple.opacity(0.3))
                                    }
                                }
                            )
                        
                        // Add Badge
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: { checkCameraPermissionAndOpen() }) {
                                    Circle()
                                        .fill(Color(hex: "6C38FF"))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .foregroundColor(.white)
                                                .font(.system(size: 18, weight: .bold))
                                        )
                                }
                                .offset(x: -15, y: -15)
                            }
                        }
                        .frame(width: 190, height: 190)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { checkCameraPermissionAndOpen() }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("photo_take_new".localized())
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 240)
                            .padding(.vertical, 14)
                            .background(Color(hex: "6C38FF"))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            sourceType = .photoLibrary
                            showImagePicker = true
                        }) {
                            Text("photo_select_gallery".localized())
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    // Tips Section
                    VStack(alignment: .center, spacing: 16) {
                        Text("photo_tips_title".localized())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            TipItem(icon: "person.crop.circle.badge.checkmark", text: "photo_tip_1".localized())
                            TipItem(icon: "sun.max", text: "photo_tip_2".localized())
                            TipItem(icon: "tshirt", text: "photo_tip_3".localized())
                            TipItem(icon: "face.smiling", text: "photo_tip_4".localized())
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    .padding(.horizontal, 16)
                    
                    // Examples Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("photo_examples_title".localized())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 10) {
                            ExampleItem(imageName: "ceo_profile_1", isCorrect: true)
                            ExampleItem(imageName: "ceo_profile_2", isCorrect: true)
                            ExampleItem(imageName: "ceo_profile_3", isCorrect: true)
                            ExampleItem(imageName: "ceo_profile_4", isCorrect: false)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Format Info Box
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .foregroundColor(AppColors.textSecondary)
                        Text("photo_format_info".localized())
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    .padding(.horizontal, 16)
                    
                    // Continue Button
                    Button(action: {
                        withAnimation {
                            supabaseManager.isAuthenticated = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
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
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Uyarı"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .id(langManager.currentLanguage)
    }
    private func checkCameraPermissionAndOpen() {
        // Check if camera is available (Simulators don't have cameras)
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertMessage = "Bu cihazda kamera kullanılamıyor."
            showAlert = true
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            sourceType = .camera
            showImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        sourceType = .camera
                        showImagePicker = true
                    }
                }
            }
        case .denied, .restricted:
            alertMessage = "Kamera erişimi reddedildi. Lütfen ayarlardan izin verin."
            showAlert = true
        @unknown default:
            break
        }
    }
}

// MARK: - Subviews
struct TipItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .font(.system(size: 18))
            }
            Text(text)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
        }
    }
}

struct ExampleItem: View {
    let imageName: String
    let isCorrect: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isCorrect ? .green : .red)
                .background(Circle().fill(.white).padding(2))
                .font(.system(size: 16))
                .offset(x: 4, y: 4)
        }
    }
}

// MARK: - Image Picker Helper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true // Added editing support for profile photos
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
