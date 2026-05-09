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
    
    // MARK: - AI Moderation (Real-time AI Check)
    func checkWithAI(texts: [String]) async throws -> (isAppropriate: Bool, reason: String?) {
        // OpenAI Moderation API or Gemini API integration
        // For production, move the API key to a secure backend/Supabase Edge Function
        let apiKey = "YOUR_API_KEY_HERE" 
        guard apiKey != "YOUR_API_KEY_HERE" else {
            // If no API key, fall back to local check but simulate AI delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            return isContentAppropriate(texts)
        }
        
        let endpoint = "https://api.openai.com/v1/moderations"
        let combinedText = texts.joined(separator: "\n---\n")
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = ["input": combinedText]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            return isContentAppropriate(texts) // Fallback
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let results = json["results"] as? [[String: Any]],
           let firstResult = results.first {
            let flagged = firstResult["flagged"] as? Bool ?? false
            if flagged {
                return (false, "İçeriğiniz AI tarafından uygunsuz bulundu.")
            }
        }
        
        return (true, nil)
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
