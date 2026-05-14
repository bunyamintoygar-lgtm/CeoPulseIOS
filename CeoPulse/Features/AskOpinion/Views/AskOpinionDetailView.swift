import SwiftUI
import UniformTypeIdentifiers

struct AskOpinionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: AskOpinionDetailViewModel
    @State private var isFileImporterPresented = false
    @State private var showDeleteAlert = false
    @State private var responseToDelete: OpinionResponse?
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        opinionDetailSection
                        
                        if !viewModel.opinion.attachments.isEmpty {
                            attachmentsSection
                        }
                        
                        responseInputSection
                        
                        responsesListSection
                    }
                    .padding(.top, 10)
                }
                
                // footerSection removed as requested
            }
        }
        .navigationBarHidden(true)
        .alert("Yanıtı Sil", isPresented: $showDeleteAlert) {
            Button("Sil", role: .destructive) {
                if let response = responseToDelete {
                    viewModel.deleteResponse(response)
                }
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu yanıtı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 22))
                Text("Ask Opinion")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Icons removed as requested
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var opinionDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category & Time
            HStack {
                let categoryName = ConfigManager.shared.opinionCategories.first(where: { $0.id == viewModel.opinion.category })?.name ?? viewModel.opinion.category
                
                Text(categoryName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                
                Text("• \(viewModel.opinion.createdAt.timeAgoDisplay())")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
            
            // Author
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.opinion.authorName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(viewModel.opinion.authorTitle)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye")
                        Text("\(viewModel.opinion.viewCount)")
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                        Text("\(viewModel.opinion.responseCount)")
                    }
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
            .padding(.top, 8)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.opinion.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.opinion.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            
            
        }
        .padding(.horizontal, 20)
    }
    
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.opinion.attachments) { attachment in
                attachmentView(for: attachment)
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func attachmentView(for attachment: OpinionAttachment) -> some View {
        switch attachment.type {
        case "image":
            imageAttachmentView(attachment)
        case "doc":
            fileAttachmentView(attachment, icon: "doc.fill")
        case "link":
            linkAttachmentView(attachment)
        case "survey":
            surveyAttachmentView(attachment)
        default:
            fileAttachmentView(attachment, icon: "paperclip")
        }
    }
    
    private func imageAttachmentView(_ attachment: OpinionAttachment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: attachment.url ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .overlay(ProgressView().tint(.white))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .cornerRadius(16)
            .clipped()
            
            Text(attachment.name)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private func fileAttachmentView(_ attachment: OpinionAttachment, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.purple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text("Dosya")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.down.circle")
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
    
    private func linkAttachmentView(_ attachment: OpinionAttachment) -> some View {
        Link(destination: URL(string: attachment.url ?? "https://google.com") ?? URL(string: "https://google.com")!) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(attachment.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text(attachment.url ?? "")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
    
    private func surveyAttachmentView(_ attachment: OpinionAttachment) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 14))
                Text("Anket")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.purple)
                Spacer()
            }
            
            if let survey = attachment.survey {
                Text(survey.question)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    ForEach(survey.options, id: \.self) { option in
                        HStack {
                            Text(option)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                .frame(width: 18, height: 18)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
                
                if survey.allowMultiple {
                    Text("* Birden fazla seçim yapabilirsiniz")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.purple.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1))
    }
    
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(viewModel.editingResponseId == nil ? "Yanıtınızı Paylaşın" : "Yanıtı Düzenle")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(viewModel.editingResponseId == nil ? .white : .purple)
                
                Spacer()
                
                if viewModel.editingResponseId == nil {
                    HStack(spacing: 8) {
                        Text("Gizli Yanıt")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                        Toggle("", isOn: $viewModel.isAnonymous)
                            .labelsHidden()
                            .scaleEffect(0.7)
                    }
                }
            }
            
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    if viewModel.newResponseText.isEmpty {
                        Text("Görüşünüzü buraya yazın...")
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                    }
                    
                    TextEditor(text: $viewModel.newResponseText)
                        .frame(height: 120)
                        .padding(8)
                        .scrollContentBackground(.hidden) // Remove default background
                        .background(Color.white.opacity(0.03))
                        .foregroundColor(.white)
                }
                .cornerRadius(12, corners: [.topLeft, .topRight])
                
                // Attachments List
                if !viewModel.attachments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.attachments) { attachment in
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.fill")
                                        .font(.system(size: 10))
                                    Text(attachment.name)
                                        .font(.system(size: 10, weight: .medium))
                                    Button(action: { viewModel.removeAttachment(attachment) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 12))
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(10)
                    }
                    .background(Color.white.opacity(0.02))
                }
                
                HStack(spacing: 12) {
                    if viewModel.editingResponseId != nil {
                        Button(action: { viewModel.cancelEditing() }) {
                            Text("Vazgeç")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    
                    Button(action: { isFileImporterPresented = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperclip")
                            Text("Dosya Ekle")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await viewModel.submitResponse() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(viewModel.editingResponseId == nil ? "Yanıtla" : "Güncelle")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(viewModel.newResponseText.isEmpty)
                    .opacity(viewModel.newResponseText.isEmpty ? 0.5 : 1.0)
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.pdf, .text, .plainText, .image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.addAttachment(name: url.lastPathComponent, url: url.absoluteString)
                }
            case .failure(let error):
                print("File selection error: \(error)")
            }
        }
    }
    
    private var responsesListSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Mevcut Yanıtlar (\(viewModel.responses.count))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("En Beğenilen")
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundColor(.white)
                }
            }
            
            LazyVStack(spacing: 16) {
                ForEach(viewModel.responses) { response in
                    ResponseCard(
                        response: response,
                        currentUserId: viewModel.currentUserId,
                        onLike: { viewModel.toggleLike(for: response) },
                        onDelete: {
                            responseToDelete = response
                            showDeleteAlert = true
                        },
                        onEdit: {
                            viewModel.editingResponseId = response.id
                            viewModel.newResponseText = response.content
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
}

struct ResponseCard: View {
    let response: OpinionResponse
    let currentUserId: UUID
    let onLike: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                if response.isAnonymous {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "eye.slash.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: 16))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Gizli Kullanıcı")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("CEO Pulse Üyesi")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 16))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(response.authorName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text(response.authorTitle)
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if response.isBestResponse {
                    Text("En Beğenilen Yanıt")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                }
                
                if response.authorId == currentUserId {
                    HStack(spacing: 8) {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(.purple)
                                .padding(8)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            Text("\(response.createdAt.timeAgoDisplay())")
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, -8)
            
            Text(response.content)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(3)
            
            HStack {
                HStack(spacing: 16) {
                    Label("\(response.likeCount)", systemImage: response.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                }
                .font(.system(size: 11))
                .foregroundColor(response.isLiked ? .purple : AppColors.textSecondary)
                
                Spacer()
                
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: response.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        Text(response.isLiked ? "Beğendin" : "Beğen")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(response.isLiked ? .purple : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(response.isLiked ? Color.purple.opacity(0.2) : Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}
