import SwiftUI

struct AskOpinionStepper: View {
    let currentStep: Int
    let steps = [
        "ao_step1".localized(),
        "ao_step2".localized(),
        "ao_step3".localized(),
        "ao_step4".localized()
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { index in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(index + 1 <= currentStep ? AppColors.primary : Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(index + 1 <= currentStep ? .white : AppColors.textSecondary)
                    }
                    
                    Text(steps[index])
                        .font(.system(size: 10))
                        .foregroundColor(index + 1 <= currentStep ? AppColors.primaryAccent : AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(height: 24)
                }
                
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(index + 1 < currentStep ? AppColors.primary : Color.white.opacity(0.1))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .offset(y: -16)
                }
            }
        }
    }
}
