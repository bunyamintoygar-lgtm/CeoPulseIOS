import Foundation
import SwiftUI
import Combine

class CreateRoundtableViewModel: ObservableObject {
    // Step 1: Masa Bilgileri
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedCategory: String = ""
    
    var categories: [LocalizedValue] {
        let items = ConfigManager.shared.roundtableCategories
        return items.isEmpty ? [
            LocalizedValue(id: "1", tr: "Liderlik", en: "Leadership", icon: "person.fill"),
            LocalizedValue(id: "2", tr: "Teknoloji", en: "Technology", icon: "cpu"),
            LocalizedValue(id: "3", tr: "Finans", en: "Finance", icon: "chart.line.uptrend.xyaxis")
        ] : items
    }
    
    func getCategoryName(_ category: LocalizedValue) -> String {
        ConfigManager.shared.getLocalizedValue(category)
    }
    
    // Step 2: Oturum Ayarları
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date = Date()
    @Published var estimatedDuration: String = "60 dakika"
    @Published var participantCount: String = "6 - 12 kişi"
    @Published var tableType: RoundtableType = .open
    
    var participantCounts: [String] {
        let counts = ConfigManager.shared.roundtableParticipantCounts.map { ConfigManager.shared.getLocalizedValue($0) }
        return counts.isEmpty ? ["3 - 6 kişi", "6 - 12 kişi", "12 - 20 kişi", "20+ kişi"] : counts
    }
    
    var durations: [String] {
        let items = ConfigManager.shared.roundtableDurations.map { ConfigManager.shared.getLocalizedValue($0) }
        return items.isEmpty ? ["45 dakika", "60 dakika", "90 dakika", "120 dakika"] : items
    }
    @Published var whoCanJoin: JoinPermission = .everyone
    
    // Step 3: Konuşma Çerçevesi
    @Published var discussionQuestions: [String] = []
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
