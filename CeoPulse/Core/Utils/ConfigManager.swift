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
    @Published var surveyCategories: [SurveyCategory] = []
    @Published var isLoading = false
    
    private init() {}
    
    @MainActor
    func fetchConfigs() async {
        isLoading = true
        do {
            let response = try await SupabaseManager.shared.client
                .from("app_config")
                .select()
                .execute()
            
            let responseData = response.data
            let decoder = JSONDecoder()
            
            // Raw representation to get the keys and raw values
            struct RawConfigItem: Decodable {
                let key: String
                let value: AnyDecodable // Custom helper or use generic decoding
            }
            
            // Instead of a complex generic, let's decode to a dictionary first
            // Supabase returns an array of objects: [{key: "...", value: ...}, ...]
            let rawArray = try JSONSerialization.jsonObject(with: responseData) as? [[String: Any]] ?? []
            
            for item in rawArray {
                guard let key = item["key"] as? String,
                      let value = item["value"] else { continue }
                
                let valueData = try JSONSerialization.data(withJSONObject: value)
                
                switch key {
                case "interests_list": self.interestsList = (try? decoder.decode([LocalizedValue].self, from: valueData)) ?? []
                case "positions": self.positions = (try? decoder.decode([LocalizedValue].self, from: valueData)) ?? []
                case "skills_list": self.skillsList = (try? decoder.decode([LocalizedValue].self, from: valueData)) ?? []
                case "sectors": self.sectors = (try? decoder.decode([LocalizedValue].self, from: valueData)) ?? []
                case "durations": self.durations = (try? decoder.decode([LocalizedValue].self, from: valueData)) ?? []
                case "company_sizes": self.companySizes = (try? decoder.decode([LocalizedValue].self, from: valueData)) ?? []
                case "survey_categories": self.surveyCategories = (try? decoder.decode([SurveyCategory].self, from: valueData)) ?? []
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
