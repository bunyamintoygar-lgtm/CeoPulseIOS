import Foundation
import SwiftUI
import Combine

class AskOpinionDetailViewModel: NSObject, ObservableObject {
    @Published var opinion: Opinion
    @Published var responses: [OpinionResponse] = []
    @Published var newResponseText: String = ""
    @Published var isAnonymous: Bool = false
    @Published var isLoading = false
    @Published var attachments: [OpinionAttachment] = []
    
    private let service = AskOpinionService.shared
    
    init(opinion: Opinion) {
        self.opinion = opinion
        super.init()
        loadDummyResponses()
    }
    
    func addAttachment(name: String, url: String) {
        let newAttachment = OpinionAttachment(name: name, type: "doc", url: url)
        attachments.append(newAttachment)
    }
    
    func removeAttachment(_ attachment: OpinionAttachment) {
        attachments.removeAll { $0.id == attachment.id }
    }
    
    func loadDummyResponses() {
        responses = [
            OpinionResponse(
                id: UUID(),
                opinionId: opinion.id,
                authorId: UUID(),
                authorName: "Mehmet A.",
                authorTitle: "Ürün Yöneticisi",
                authorAvatar: nil,
                content: "Düzenli ve şeffaf iletişim en kritik nokta. Haftalık ekip buluşmaları, birebir görüşmeler ve açık geri bildirim kültürü ile ekibimizin bağlılığını önemli ölçüde artırdık. Ayrıca, başarıları kutlamayı ihmal etmiyoruz.",
                likeCount: 12,
                commentCount: 3,
                isBestResponse: true,
                isAnonymous: false,
                createdAt: Date().addingTimeInterval(-18000)
            )
        ]
    }
    
    @MainActor
    func submitResponse() async {
        guard !newResponseText.isEmpty else { return }
        
        isLoading = true
        
        // Simulating network delay and response addition
        try? await Task.sleep(nanoseconds: 1_000_000_000) 
        
        let newResponse = OpinionResponse(
            id: UUID(),
            opinionId: opinion.id,
            authorId: UUID(), // Current user ID placeholder
            authorName: "Siz", 
            authorTitle: "CEO",
            authorAvatar: nil,
            content: newResponseText,
            likeCount: 0,
            commentCount: 0,
            isBestResponse: false,
            isAnonymous: isAnonymous,
            createdAt: Date()
        )
        
        responses.insert(newResponse, at: 0)
        newResponseText = ""
        isLoading = false
    }
}
