import SwiftUI

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(isMet ? .green : Color.white.opacity(0.2))
            Text(text)
                .font(.system(size: 10))
                .foregroundColor(isMet ? .white : Color.white.opacity(0.5))
        }
    }
}

struct CustomAuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var isVisible: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 20)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 16))
                }
                
                if isSecure && !isVisible {
                    SecureField("", text: $text)
                        .foregroundColor(.white)
                } else {
                    TextField("", text: $text)
                        .foregroundColor(.white)
                }
            }
            
            if isSecure {
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye" : "eye.slash")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .purple : AppColors.textSecondary)
                .font(.system(size: 20))
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}
