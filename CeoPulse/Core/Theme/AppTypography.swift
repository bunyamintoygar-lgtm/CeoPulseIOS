import SwiftUI

struct AppTypography {
    static func titleLarge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(AppColors.textPrimary)
    }
    
    static func titleMedium(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(AppColors.textPrimary)
    }
    
    static func bodyMedium(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AppColors.textSecondary)
    }
    
    static func caption(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(AppColors.textSecondary)
    }
}

extension View {
    func premiumTitle() -> some View {
        self.font(.system(size: 24, weight: .bold))
            .foregroundColor(AppColors.textPrimary)
    }
    
    func premiumBody() -> some View {
        self.font(.system(size: 14, weight: .medium))
            .foregroundColor(AppColors.textSecondary)
    }
}
