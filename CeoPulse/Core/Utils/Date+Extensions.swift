import Foundation

extension Date {
    func daysFromNow() -> Int {
        let calendar = Calendar.current
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTarget)
        return components.day ?? 0
    }
    
    func timeRemaining() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if self <= now {
            return "Süre Doldu"
        }
        
        let components = calendar.dateComponents([.day, .hour], from: now, to: self)
        
        if let day = components.day, day > 0 {
            return "\(day) gün kaldı"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) saat kaldı"
        } else {
            return "Az önce"
        }
    }
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
