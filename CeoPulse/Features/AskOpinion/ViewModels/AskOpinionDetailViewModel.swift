import Foundation
import SwiftUI

class AskOpinionDetailViewModel: ObservableObject {
    @Published var opinion: Opinion
    @Published var responses: [OpinionResponse] = []
    @Published var newResponseText: String = ""
    @Published var isAnonymous: Bool = false
    @Published var isLoading = false
    
    private let service = AskOpinionService.shared
    
    init(opinion: Opinion) {
        self.opinion = opinion
        loadDummyResponses()
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
        
        // In a real app, this would call the service to save the response to Supabase
        // And then refresh the list
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network
        
        let newResponse = OpinionResponse(
            id: UUID(),
            opinionId: opinion.id,
            authorId: UUID(), // Current user ID
            authorName: "Siz", // Current user name
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
