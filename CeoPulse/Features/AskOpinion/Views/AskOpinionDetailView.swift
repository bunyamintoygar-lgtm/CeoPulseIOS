import SwiftUI

struct AskOpinionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: AskOpinionDetailViewModel
    @State private var isFileImporterPresented = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        opinionDetailSection
                        
                        responseInputSection
                        
                        responsesListSection
                    }
                    .padding(.top, 10)
                }
                
                footerSection
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
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
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 14, height: 14)
                        .overlay(Text("3").font(.system(size: 8, weight: .bold)).foregroundColor(.white))
                        .offset(x: 4, y: -4)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                    Text("PREMIUM")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var opinionDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category & Time
            HStack {
                Text(viewModel.opinion.category)
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
                
                HStack(spacing: 20) {
                    Image(systemName: "bookmark")
                    Image(systemName: "hand.thumbsup")
                    Image(systemName: "ellipsis")
                }
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
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
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Açık")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Text("Yanıtlanmaya devam ediyor")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }
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
            
            // Stats
            HStack {
                statItem(icon: "eye", value: "\(viewModel.opinion.viewCount)", label: "Görüntüleme")
                Spacer()
                statItem(icon: "bubble.left", value: "\(viewModel.opinion.responseCount)", label: "Yanıt")
                Spacer()
                statItem(icon: "hand.thumbsup", value: "\(viewModel.opinion.likeCount)", label: "Beğeni")
            }
            .padding(.vertical, 8)
            
            // Info Banner
            HStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .foregroundColor(.purple)
                Text("Görüşleriniz topluluğumuzda yayınlanır ve ilgili kişiler tarafından görülebilir.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(value)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private var responseInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Yanıtınızı Paylaşın")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("Anonim olarak gönder")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                    Toggle("", isOn: $viewModel.isAnonymous)
                        .labelsHidden()
                        .scaleEffect(0.7)
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
                
                HStack {
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
                            Text("Yanıtla")
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
                    ResponseCard(response: response)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var footerSection: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.purple)
            Text("Bu soruya yanıt vererek topluluğa katkıda bulunun")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.purple.opacity(0.1))
        .padding(.bottom, 10)
    }
}

struct ResponseCard: View {
    let response: OpinionResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
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
                
                Image(systemName: "ellipsis")
                    .foregroundColor(AppColors.textSecondary)
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
                    Label("\(response.likeCount)", systemImage: "hand.thumbsup")
                    Label("\(response.commentCount)", systemImage: "bubble.left")
                }
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.thumbsup")
                        Text("Beğen")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
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
