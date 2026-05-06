import Foundation
import Combine
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
            // Using PostgrestResponse to get data
            let response = try await SupabaseManager.shared.client
                .from("app_config")
                .select()
                .execute()
            
            let responseData = response.data
            // Since data is Data, we should decode it properly
            let decoder = JSONDecoder()
            struct ConfigItem: Decodable {
                let key: String
                let value: [LocalizedValue]
            }
            
            let configs = try decoder.decode([ConfigItem].self, from: responseData)
            
            for item in configs {
                switch item.key {
                case "interests_list": self.interestsList = item.value
                case "positions": self.positions = item.value
                case "skills_list": self.skillsList = item.value
                case "sectors": self.sectors = item.value
                case "durations": self.durations = item.value
                case "company_sizes": self.companySizes = item.value
                default: break
                }
            }
            
        } catch {
            print("Config fetch error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // Helper to get localized string
    func getLocalizedValue(_ value: LocalizedValue) -> String {
        let languageCode: String
        if #available(iOS 16.0, *) {
            languageCode = Locale.current.language.languageCode?.identifier ?? "tr"
        } else {
            languageCode = Locale.current.languageCode ?? "tr"
        }
        return languageCode == "en" ? value.en : value.tr
    }
}

struct LocalizedValue: Codable, Hashable {
    let id: String
    let tr: String
    let en: String
}
