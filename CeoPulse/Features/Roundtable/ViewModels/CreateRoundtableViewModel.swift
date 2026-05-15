import Foundation
import SwiftUI
import Combine
import Supabase

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
    @Published var isSuccess: Bool = false
    
    enum RoundtableType: String {
        case open = "open"
        case invited = "invited"
    }
    
    enum JoinPermission: String {
        case everyone = "everyone"
        case premium = "premium"
        case invitedOnly = "invitedOnly"
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
    
    // Internal struct for Supabase insertion with explicit ISO8601 date string
    struct CreateRoundtableRequest: Encodable {
        let title: String
        let description: String
        let category: String
        let status: String
        let start_time: String // Using String to ensure ISO8601
        let estimated_duration: String
        let participant_limit: String
        let join_policy: String
        let table_type: String
        let questions: [String]
        let moderator_id: UUID
    }
    
    @MainActor
    func createRoundtable() async {
        guard validate() else { 
            print("Validation failed: \(errorMessage)")
            return 
        }
        
        isLoading = true
        showError = false
        
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let userId = session.user.id
            
            // Combine date and time
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            
            let startTimeDate = calendar.date(from: components) ?? selectedDate
            let isoFormatter = ISO8601DateFormatter()
            let startTimeString = isoFormatter.string(from: startTimeDate)
            
            let request = CreateRoundtableRequest(
                title: title,
                description: description,
                category: selectedCategory,
                status: "upcoming",
                start_time: startTimeString,
                estimated_duration: estimatedDuration,
                participant_limit: participantCount,
                join_policy: whoCanJoin.rawValue,
                table_type: tableType.rawValue,
                questions: discussionQuestions,
                moderator_id: userId
            )
            
            try await SupabaseManager.shared.client
                .from("roundtables")
                .insert(request)
                .execute()
            
            isSuccess = true
            isLoading = false
        } catch {
            print("Roundtable creation error: \(error)")
            errorMessage = "Kayıt sırasında bir hata oluştu: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    private func validate() -> Bool {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Lütfen masa başlığını girin."
            showError = true
            return false
        }
        if selectedCategory.isEmpty {
            errorMessage = "Lütfen bir kategori seçin."
            showError = true
            return false
        }
        return true
    }
}
