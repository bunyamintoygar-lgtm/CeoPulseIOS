import Foundation
import Supabase

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var positions: [String] = []
    @Published var companySizes: [String] = []
    @Published var durations: [String] = []
    @Published var sectors: [String] = []
    @Published var skillsList: [String] = []
    @Published var interestsList: [LocalizedValue] = []
    @Published var isLoading = false
    
    private init() {}
    
    @MainActor
    func fetchConfigs() async {
        isLoading = true
        do {
            let response: [[String: Any]] = try await SupabaseManager.shared.client
                .from("app_config")
                .select()
                .execute()
                .value
            
            for item in response {
                guard let key = item["key"] as? String else { continue }
                
                if key == "interests_list", let data = item["value"] as? [[String: String]] {
                    let decoder = JSONDecoder()
                    if let jsonData = try? JSONSerialization.data(withJSONObject: data),
                       let decodedInterests = try? decoder.decode([LocalizedValue].self, from: jsonData) {
                        self.interestsList = decodedInterests
                    }
                } else if let value = item["value"] as? [String] {
                    switch key {
                    case "positions": self.positions = value
                    case "company_sizes": self.companySizes = value
                    case "durations": self.durations = value
                    case "sectors": self.sectors = value
                    case "skills_list": self.skillsList = value
                    default: break
                    }
                }
            }
        } catch {
            print("Config fetch error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // Helper to get localized string
    func getLocalizedInterest(_ interest: LocalizedValue) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "tr"
        return languageCode == "en" ? interest.en : interest.tr
    }
}

struct LocalizedValue: Codable, Hashable {
    let id: String
    let tr: String
    let en: String
}
