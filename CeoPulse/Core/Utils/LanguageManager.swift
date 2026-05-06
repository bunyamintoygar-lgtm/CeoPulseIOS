import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        self.currentLanguage = (UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String) ?? "tr"
    }
    
    func setLanguage(_ language: String) {
        withAnimation {
            currentLanguage = language
        }
    }
}
