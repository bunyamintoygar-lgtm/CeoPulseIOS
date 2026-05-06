import SwiftUI
import PhotosUI

struct ProfilePhotoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var supabaseManager: SupabaseManager
    @StateObject private var langManager = LanguageManager.shared
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header (No back button as requested)
                Spacer().frame(height: 20)
                
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
                
                // Redesigned Photo Frame
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.5), .purple, .blue.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(selectedImage == nil ? 0 : 360))
                        .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: selectedImage == nil)
                    
                    // Inner Circle
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 200, height: 200)
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
                                        .foregroundColor(.white.opacity(0.2))
                                }
                            }
                        )
                    
                    // Add/Edit Badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color(hex: "6C38FF"))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: selectedImage == nil ? "camera.fill" : "pencil")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .bold))
                                )
                                .shadow(color: Color(hex: "6C38FF").opacity(0.5), radius: 10)
                        }
                    }
                    .frame(width: 200, height: 200)
                }
                .padding(.vertical, 20)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        sourceType = .camera
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("photo_take_new".localized())
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C38FF"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("photo_select_gallery".localized())
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Bottom Button
                Button(action: {
                    withAnimation {
                        supabaseManager.isAuthenticated = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Text("continue".localized())
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(selectedImage != nil ? Color(hex: "6C38FF") : Color.white.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .id(langManager.currentLanguage)
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
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
