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
    let currentUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    
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
        responses = []
    }
    
    @Published var editingResponseId: UUID?
    
    @MainActor
    func submitResponse() async {
        guard !newResponseText.isEmpty else { return }
        
        isLoading = true
        
        // Simulating network delay and response addition
        try? await Task.sleep(nanoseconds: 1_000_000_000) 
        
        if let editingId = editingResponseId {
            if let index = responses.firstIndex(where: { $0.id == editingId }) {
                withAnimation {
                    responses[index].content = newResponseText
                }
            }
            editingResponseId = nil
        } else {
            let newResponse = OpinionResponse(
                id: UUID(),
                opinionId: opinion.id,
                authorId: currentUserId, 
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
            
            withAnimation {
                responses.insert(newResponse, at: 0)
            }
        }
        
        newResponseText = ""
        isLoading = false
    }

    func cancelEditing() {
        editingResponseId = nil
        newResponseText = ""
    }

    func toggleLike(for response: OpinionResponse) {
        if let index = responses.firstIndex(where: { $0.id == response.id }) {
            withAnimation {
                if responses[index].isLiked {
                    responses[index].likeCount -= 1
                    responses[index].isLiked = false
                } else {
                    responses[index].likeCount += 1
                    responses[index].isLiked = true
                }
            }
        }
    }

    func deleteResponse(_ response: OpinionResponse) {
        withAnimation {
            responses.removeAll { $0.id == response.id }
        }
    }

}
