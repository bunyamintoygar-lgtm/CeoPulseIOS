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
    
    // MARK: - AI Moderation (via Supabase Edge Function)
    func checkWithAI(texts: [String]) async throws -> (isAppropriate: Bool, reason: String?) {
        let combinedText = texts.joined(separator: "\n---\n")
        
        do {
            // Call the 'moderate-content' Edge Function
            let response = try await SupabaseManager.shared.client.functions
                .invoke(
                    "moderate-content", 
                    options: .init(
                        body: ["text": combinedText],
                        method: .post
                    )
                )
            
            // Supabase Edge Functions return data as raw Data
            let decoder = JSONDecoder()
            if let result = try? decoder.decode(ModerationResponse.self, from: response) {
                if result.flagged {
                    return (false, result.reason ?? "İçeriğiniz uygunsuz bulundu.")
                }
                return (true, nil)
            }
            
            return (true, nil) // Default to pass if decode fails
        } catch {
            print("Edge Function Moderation Error: \(error)")
            // Fallback to local check if function fails
            return isContentAppropriate(texts)
        }
    }
    
    private struct ModerationResponse: Codable {
        let flagged: Bool
        let reason: String?
    }
    
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
