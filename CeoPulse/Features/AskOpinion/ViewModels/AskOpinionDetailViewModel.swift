import Foundation
import SwiftUI
import Combine
import Supabase
import Auth

enum ResponseSortOption: String, CaseIterable {
    case topLiked = "topLiked"
    case newest = "newest"
    
    var displayTitle: String {
        switch self {
        case .topLiked: return "ao_sort_top_liked".localized()
        case .newest: return "ao_sort_newest".localized()
        }
    }
}

class AskOpinionDetailViewModel: NSObject, ObservableObject {
    @Published var opinion: Opinion
    @Published var responses: [OpinionResponse] = []
    @Published var newResponseText: String = ""
    @Published var isAnonymous: Bool = false
    @Published var isLoading = false
    @Published var attachments: [OpinionAttachment] = []
    @Published var sortOption: ResponseSortOption = .topLiked {
        didSet { sortResponses() }
    }
    
    private let service = AskOpinionService.shared
    
    var currentUserId: UUID {
        // In a real app, this should come from a proper AuthManager or Session
        // For now, we try to get it from the Supabase client session
        // If no session, we use a fallback (which might fail FK constraints)
        return SupabaseManager.shared.client.auth.currentSession?.user.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    }
    
    init(opinion: Opinion) {
        self.opinion = opinion
        super.init()
        Task {
            await fetchResponses()
            try? await service.incrementViewCount(opinionId: opinion.id)
            await MainActor.run {
                self.opinion.viewCount += 1
            }
        }
    }
    
    func addAttachment(name: String, url: String) {
        let newAttachment = OpinionAttachment(name: name, type: "doc", url: url)
        attachments.append(newAttachment)
    }
    
    func removeAttachment(_ attachment: OpinionAttachment) {
        attachments.removeAll { $0.id == attachment.id }
    }
    
    @MainActor
    func fetchResponses() async {
        isLoading = true
        do {
            let fetchedResponses = try await service.fetchResponses(opinionId: opinion.id, currentUserId: currentUserId)
            self.responses = fetchedResponses
            sortResponses()
        } catch {
            print("Error fetching responses: \(error)")
        }
        isLoading = false
    }
    
    @Published var editingResponseId: UUID?
    
    @MainActor
    func submitResponse() async {
        guard !newResponseText.isEmpty else { return }
        
        isLoading = true
        print("DEBUG: Submitting response for user: \(currentUserId)")
        
        do {
            if let editingId = editingResponseId {
                try await service.updateResponse(responseId: editingId, content: newResponseText)
                if let index = responses.firstIndex(where: { $0.id == editingId }) {
                    withAnimation {
                        responses[index].content = newResponseText
                    }
                }
                editingResponseId = nil
            } else {
                let newResponse = try await service.createResponse(
                    opinionId: opinion.id,
                    authorId: currentUserId,
                    content: newResponseText,
                    isAnonymous: isAnonymous,
                    attachments: attachments
                )
                
                withAnimation {
                    responses.insert(newResponse, at: 0)
                }
            }
            
            sortResponses()
            newResponseText = ""
            attachments = [] // Clear attachments after successful submission
        } catch {
            print("Error submitting response: \(error)")
        }
        
        isLoading = false
    }

    func cancelEditing() {
        editingResponseId = nil
        newResponseText = ""
    }

    func toggleLike(for response: OpinionResponse) {
        if let index = responses.firstIndex(where: { $0.id == response.id }) {
            let wasLiked = responses[index].isLiked
            let newLikedStatus = !wasLiked
            
            // Optimistic UI update
            withAnimation {
                responses[index].isLiked = newLikedStatus
                responses[index].likeCount += newLikedStatus ? 1 : -1
            }
            sortResponses()
            
            // Persist to DB
            Task {
                do {
                    try await service.toggleLikeResponse(
                        responseId: response.id,
                        userId: currentUserId,
                        isLiked: newLikedStatus
                    )
                } catch {
                    print("Error toggling like: \(error)")
                    // Revert UI on error
                    await MainActor.run {
                        withAnimation {
                            responses[index].isLiked = wasLiked
                            responses[index].likeCount += wasLiked ? 1 : -1
                        }
                    }
                }
            }
        }
    }

    func sortResponses() {
        withAnimation {
            switch sortOption {
            case .topLiked:
                responses.sort { ($0.likeCount, $0.createdAt) > ($1.likeCount, $1.createdAt) }
            case .newest:
                responses.sort { $0.createdAt > $1.createdAt }
            }
        }
    }

    @MainActor
    func deleteResponse(_ response: OpinionResponse) {
        isLoading = true
        Task {
            do {
                try await service.deleteResponse(responseId: response.id)
                withAnimation {
                    responses.removeAll { $0.id == response.id }
                }
            } catch {
                print("Error deleting response: \(error)")
            }
            isLoading = false
        }
    }
}
