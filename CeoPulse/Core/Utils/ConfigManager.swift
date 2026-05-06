import Foundation
import Supabase

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var positions: [String] = []
    @Published var companySizes: [String] = []
    @Published var durations: [String] = []
    @Published var sectors: [String] = []
    @Published var skillsList: [String] = []
    @Published var interestsList: [String] = []
    @Published var isLoading = false
    
    private init() {}
    
    @MainActor
    func fetchConfigs() async {
        isLoading = true
        do {
            let configs: [AppConfig] = try await SupabaseManager.shared.client
                .from("app_config")
                .select()
                .execute()
                .value
            
                switch config.key {
                case "positions": self.positions = config.value
                case "company_sizes": self.companySizes = config.value
                case "durations": self.durations = config.value
                case "sectors": self.sectors = config.value
                case "skills_list": self.skillsList = config.value
                case "interests_list": self.interestsList = config.value
                default: break
                }
        } catch {
            print("Config fetch error: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

struct AppConfig: Codable {
    let key: String
    let value: [String]
}
