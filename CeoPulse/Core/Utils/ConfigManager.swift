import Foundation
import Supabase

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var positions: [LocalizedValue] = []
    @Published var companySizes: [LocalizedValue] = []
    @Published var durations: [LocalizedValue] = []
    @Published var sectors: [LocalizedValue] = []
    @Published var skillsList: [LocalizedValue] = []
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
                guard let key = item["key"] as? String,
                      let data = item["value"] as? [[String: String]] else { continue }
                
                let decoder = JSONDecoder()
                if let jsonData = try? JSONSerialization.data(withJSONObject: data),
                   let decodedValues = try? decoder.decode([LocalizedValue].self, from: jsonData) {
                    switch key {
                    case "interests_list": self.interestsList = decodedValues
                    case "positions": self.positions = decodedValues
                    case "skills_list": self.skillsList = decodedValues
                    case "sectors": self.sectors = decodedValues
                    case "durations": self.durations = decodedValues
                    case "company_sizes": self.companySizes = decodedValues
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
    func getLocalizedValue(_ value: LocalizedValue) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "tr"
        return languageCode == "en" ? value.en : value.tr
    }
}

struct LocalizedValue: Codable, Hashable {
    let id: String
    let tr: String
    let en: String
}
