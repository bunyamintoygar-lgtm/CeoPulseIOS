import Foundation
import SwiftUI

class RoundtableRowViewModel: ObservableObject {
    @Published var participants: [Profile] = []
    let roundtableId: UUID
    
    init(roundtableId: UUID) {
        self.roundtableId = roundtableId
    }
    
    func fetchParticipants() {
        // In a real app, this would call a service
        // For now, we mock the data
        participants = [
            Profile(id: UUID(), name: "Ali Yılmaz", title: "CEO", avatar: "https://i.pravatar.cc/150?u=1"),
            Profile(id: UUID(), name: "Ayşe Demir", title: "CTO", avatar: "https://i.pravatar.cc/150?u=2"),
            Profile(id: UUID(), name: "Mehmet Öz", title: "COO", avatar: "https://i.pravatar.cc/150?u=3"),
            Profile(id: UUID(), name: "Selin Aras", title: "Founder", avatar: "https://i.pravatar.cc/150?u=4")
        ]
    }
}
