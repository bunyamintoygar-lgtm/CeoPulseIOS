import Foundation
import SwiftUI
import Combine

class RoundtableRowViewModel: ObservableObject {
    @Published var participants: [Profile] = []
    let roundtableId: UUID
    
    init(roundtableId: UUID) {
        self.roundtableId = roundtableId
    }
    
    func fetchParticipants() {
        // In a real app, this would call a service
        // For now, we mock the data with correct Profile fields
        participants = [
            Profile(id: UUID(), first_name: "Ali", last_name: "Yılmaz", position: "CEO", avatar_url: "https://i.pravatar.cc/150?u=1"),
            Profile(id: UUID(), first_name: "Ayşe", last_name: "Demir", position: "CTO", avatar_url: "https://i.pravatar.cc/150?u=2"),
            Profile(id: UUID(), first_name: "Mehmet", last_name: "Öz", position: "COO", avatar_url: "https://i.pravatar.cc/150?u=3"),
            Profile(id: UUID(), first_name: "Selin", last_name: "Aras", position: "Founder", avatar_url: "https://i.pravatar.cc/150?u=4")
        ]
    }
}
