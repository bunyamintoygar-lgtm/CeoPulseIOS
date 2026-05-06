import SwiftUI

struct AppColors {
    static let background = Color(hex: "080A10")
    static let surface = Color(hex: "13161F")
    static let surfaceLight = Color(hex: "1F222F")
    
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8A8E9B")
    
    static let primaryAccent = Color(hex: "6C38FF")
    static let primary = primaryAccent
    static let premiumGold = Color(hex: "FFB800")
    static let successGreen = Color(hex: "4CAF50")
    static let successGreenDark = Color(hex: "1B3320")
    
    static let border = Color(hex: "1F222F")
    
    // Gradients
    static let aiCardGradient = LinearGradient(
        colors: [Color(hex: "241B4A"), Color(hex: "2E2460")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let askOpinionGradient = LinearGradient(
        colors: [Color(hex: "162C5B"), Color(hex: "10182C")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let premiumGradient = LinearGradient(
        colors: [Color(hex: "6C38FF"), Color(hex: "8A56FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
