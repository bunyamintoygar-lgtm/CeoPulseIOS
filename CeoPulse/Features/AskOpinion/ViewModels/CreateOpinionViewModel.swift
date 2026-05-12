import Foundation
import SwiftUI
import Combine

class CreateOpinionViewModel: NSObject, ObservableObject {
    @Published var currentStep: Int = 1
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedType: Int = 0
    @Published var selectedTarget: Int = 0
    @Published var selectedPrivacy: Int = 0
    @Published var category: String = "Liderlik & Strateji"
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
        guard !title.isEmpty && !description.isEmpty else {
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
            description: description,
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
}
