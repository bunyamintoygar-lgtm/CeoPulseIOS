import SwiftUI

struct AskOpinionBanner: View {
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 32, height: 32)
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                    Text("ask_opinion".localized())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("ask_opinion_desc".localized())
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 200, alignment: .leading)
                
                NavigationLink(destination: AskOpinionView()) {
                    HStack {
                        Text("ask_question".localized())
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "7B61FF"), Color(hex: "A389FF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
            
            Spacer()
            
            // 3D Bubble Illustration (Simplified)
            ZStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .opacity(0.6)
                    .blur(radius: 1)
            }
        }
        .padding(20)
        .background(AppColors.askOpinionGradient)
        .cornerRadius(24)
    }
}

struct AskOpinionBanner_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            AskOpinionBanner()
                .padding()
        }
    }
}
