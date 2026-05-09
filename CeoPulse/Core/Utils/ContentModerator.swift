import Foundation

struct ContentModerator {
    static let shared = ContentModerator()
    
    // Proje için genişletilebilir yasaklı kelime listesi
    // Not: Gerçek bir üretim uygulamasında bu liste bir API üzerinden veya 
    // bulut tabanlı bir moderasyon servisi (örn. AWS Rekognition veya Perspective API) üzerinden yönetilmelidir.
    private let bannedWords: Set<String> = [
        "küfür1", "küfür2", "hakaret1", "argo1", // Buraya gerçek yasaklı kelimeler eklenebilir
        "müstehcen1", "uygunsuz1"
    ]
    
    func isContentAppropriate(_ texts: [String]) -> (isAppropriate: Bool, offendingWord: String?) {
        for text in texts {
            let normalizedText = text.lowercased()
                .replacingOccurrences(of: "ı", with: "i")
                .replacingOccurrences(of: "ğ", with: "g")
                .replacingOccurrences(of: "ü", with: "u")
                .replacingOccurrences(of: "ş", with: "s")
                .replacingOccurrences(of: "ö", with: "o")
                .replacingOccurrences(of: "ç", with: "c")
            
            // Kelime bazlı kontrol
            let words = normalizedText.components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
            
            for word in words {
                if bannedWords.contains(word) {
                    return (false, word)
                }
            }
            
            // Parçacık bazlı kontrol (Kelime içine gizlenmiş küfürler için)
            for banned in bannedWords {
                if normalizedText.contains(banned) {
                    return (false, banned)
                }
            }
        }
        
        return (true, nil)
    }
}
