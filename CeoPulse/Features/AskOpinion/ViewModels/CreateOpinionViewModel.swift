import Foundation
import SwiftUI
import Combine

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
        
        // Use a dummy author ID for now (In real app, get from AuthSession)
        let authorId = UUID() 
        
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
        
        do {
            try await service.createOpinion(newOpinion)
            isSuccess = true
            isLoading = false
        } catch {
            print("Error publishing opinion: \(error)")
            errorMessage = "Soru yayınlanırken bir hata oluştu. Lütfen tekrar deneyin."
            isLoading = false
        }
    }
    
    // MARK: - Attachment Management
    
    func addDocument() {
        // In a real app, trigger FilePicker
        let newDoc = OpinionAttachment(name: "Stratejik_Rapor.pdf", type: "doc", url: "https://example.com/doc", survey: nil)
        attachments.append(newDoc)
    }
    
    func addLink() {
        // In a real app, show URL input alert
        let newLink = OpinionAttachment(name: "Pazar Analizi Linki", type: "link", url: "https://market-analysis.com", survey: nil)
        attachments.append(newLink)
    }
    
    func addImage() {
        // In a real app, trigger ImagePicker
        let newImage = OpinionAttachment(name: "grafik_01.png", type: "image", url: "https://example.com/img", survey: nil)
        attachments.append(newImage)
    }
    
    func addSurvey() {
        let newSurvey = OpinionAttachment(
            name: "ao_add_survey".localized(),
            type: "survey",
            url: nil,
            survey: OpinionSurveyAttachment(question: "", options: ["", ""])
        )
        attachments.append(newSurvey)
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
