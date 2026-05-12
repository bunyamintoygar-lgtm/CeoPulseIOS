import Foundation
import SwiftUI
import Combine
import Supabase
import Auth

class CreateOpinionViewModel: NSObject, ObservableObject {
    @Published var currentStep: Int = 1
    @Published var title: String = ""
    @Published var opinionDescription: String = ""
    @Published var selectedType: Int = 0
    @Published var selectedTarget: Int = 0
    @Published var selectedPrivacy: Int = 0
    @Published var category: String = "strategy"
    @Published var categorySearchText: String = ""
    @Published var attachments: [OpinionAttachment] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    
    private let service = AskOpinionService.shared
    
    override init() {
        super.init()
    }
    
    func nextStep() {
        if currentStep < 4 {
            withAnimation {
                currentStep += 1
            }
        } else {
            Task {
                await publishOpinion()
            }
        }
    }
    
    func previousStep() {
        if currentStep > 1 {
            withAnimation {
                currentStep -= 1
            }
        }
    }
    
    @MainActor
    func publishOpinion() async {
        guard !title.isEmpty && !opinionDescription.isEmpty else {
            errorMessage = "Lütfen başlık ve açıklama alanlarını doldurun."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let authorId = session.user.id
            
            let newOpinion = Opinion(
                id: UUID(),
                authorId: authorId,
                authorName: "", // Server will fill or get from profile join
                authorTitle: "",
                authorAvatar: nil,
                title: title,
                description: opinionDescription,
                status: .open,
                category: category,
                type: selectedType,
                targetAudience: selectedTarget,
                privacyLevel: selectedPrivacy,
                attachments: attachments,
                viewCount: 0,
                responseCount: 0,
                likeCount: 0,
                createdAt: Date()
            )
            
            try await service.createOpinion(newOpinion)
            isSuccess = true
            isLoading = false
        } catch {
            print("Error publishing opinion: \(error)")
            errorMessage = "Hata: \(String(describing: error))"
            isLoading = false
        }
    }
    
    // MARK: - Attachment Management
    
    func addDocument(name: String, url: String) {
        let newDoc = OpinionAttachment(name: name, type: "doc", url: url, survey: nil)
        attachments.append(newDoc)
    }
    
    func addLink() {
        let newLink = OpinionAttachment(name: "ao_add_link".localized(), type: "link", url: "", survey: nil)
        attachments.append(newLink)
    }
    
    func updateLink(attachmentId: String, url: String) {
        if let index = attachments.firstIndex(where: { $0.id == attachmentId }) {
            attachments[index].url = url
        }
    }
    
    func addImage(name: String, url: String) {
        let newImage = OpinionAttachment(name: name, type: "image", url: url, survey: nil)
        attachments.append(newImage)
    }
    
    func addSurvey() {
        let newSurvey = OpinionAttachment(
            name: "ao_add_survey".localized(),
            type: "survey",
            url: nil,
            survey: OpinionSurveyAttachment(question: "", options: ["", ""], allowMultiple: false, isRequired: true)
        )
        attachments.append(newSurvey)
    }
    
    func toggleSurveyMultiple(attachmentId: String) {
        if let index = attachments.firstIndex(where: { $0.id == attachmentId }) {
            attachments[index].survey?.allowMultiple.toggle()
        }
    }
    
    func toggleSurveyRequired(attachmentId: String) {
        if let index = attachments.firstIndex(where: { $0.id == attachmentId }) {
            attachments[index].survey?.isRequired.toggle()
        }
    }
    
    func removeAttachment(at index: Int) {
        attachments.remove(at: index)
    }
    
    func updateSurveyOption(attachmentId: String, optionIndex: Int, text: String) {
        if let index = attachments.firstIndex(where: { $0.id == attachmentId }) {
            attachments[index].survey?.options[optionIndex] = text
        }
    }
    
    func addSurveyOption(attachmentId: String) {
        if let index = attachments.firstIndex(where: { $0.id == attachmentId }) {
            attachments[index].survey?.options.append("")
        }
    }
    
    func removeSurveyOption(attachmentId: String, optionIndex: Int) {
        if let index = attachments.firstIndex(where: { $0.id == attachmentId }) {
            if (attachments[index].survey?.options.count ?? 0) > 2 {
                attachments[index].survey?.options.remove(at: optionIndex)
            }
        }
    }
}
