import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        // Get initial language, stripping region code if present (e.g., "tr-US" -> "tr")
        let fullLang = (UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String) ?? "tr"
        self.currentLanguage = fullLang.prefix(2).lowercased()
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
    }
}
