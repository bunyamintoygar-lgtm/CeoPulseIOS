import Foundation
import SwiftUI
import Combine

class CreateRoundtableViewModel: ObservableObject {
    // Step 1: Masa Bilgileri
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedCategory: String = ""
    
    var categories: [String] {
        ConfigManager.shared.roundtableCategories.map { ConfigManager.shared.getLocalizedValue($0) }
    }
    
    // Step 2: Oturum Ayarları
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date = Date()
    @Published var estimatedDuration: String = "90 dakika"
    @Published var participantCount: String = "6 - 12 kişi"
    @Published var tableType: RoundtableType = .open
    @Published var whoCanJoin: JoinPermission = .everyone
    
    // Step 3: Konuşma Çerçevesi
    @Published var discussionQuestions: [String] = [
        "2026'da liderlerin karşılaşacağı en büyük zorluklar neler olacak?",
        "Bu zorluklara karşı hangi stratejiler en etkili olabilir?"
    ]
    @Published var newQuestion: String = ""
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    enum RoundtableType {
        case open, invited
    }
    
    enum JoinPermission {
        case everyone, premium, invitedOnly
    }
    
    func addQuestion() {
        if !newQuestion.isEmpty {
            discussionQuestions.append(newQuestion)
            newQuestion = ""
        }
    }
    
    func removeQuestion(at index: Int) {
        discussionQuestions.remove(at: index)
    }
    
    func createRoundtable() async {
        isLoading = true
        // Logic to save to Supabase would go here
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        isLoading = false
    }
}
