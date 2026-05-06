import SwiftUI

struct ProfileCompletionView: View {
    @State private var completionRate: Double = 0.65
    @State private var showPhotoFlow = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {}) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Profilinizi Tamamlayın")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("Daha güçlü bağlantılar kurmak için profilinizi\ntamamlamanızı öneriyoruz.")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Progress Card
                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                                    Circle()
                                        .trim(from: 0, to: completionRate)
                                        .stroke(LinearGradient(colors: [Color(hex: "6C38FF"), Color(hex: "8A56FF")], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                    
                                    VStack {
                                        Text("\(Int(completionRate * 100))%")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("Tamamlandı")
                                            .font(.system(size: 10))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Harika bir başlangıç!")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Profilinizi tamamlayarak görünürlüğünüzü artırın ve daha iyi eşleşmeler elde edin.")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    // Mini Progress Bar
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Color.white.opacity(0.1)).frame(height: 6)
                                            Capsule().fill(Color(hex: "6C38FF")).frame(width: geo.size.width * completionRate, height: 6)
                                        }
                                    }
                                    .frame(height: 6)
                                    
                                    HStack {
                                        Spacer()
                                        Text("13 / 20").font(.system(size: 10)).foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        
                        // Tasks List
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Tamamlanması Gerekenler").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                Spacer()
                                Text("7 adım kaldı").font(.system(size: 12)).foregroundColor(.purple)
                            }
                            
                            VStack(spacing: 12) {
                                CompletionTaskRow(icon: "person.crop.circle.badge.checkmark", title: "Profil Fotoğrafı", subtitle: "Profesyonel bir profil fotoğrafı ekleyin.", status: .completed, action: { showPhotoFlow = true })
                                CompletionTaskRow(icon: "person.text.rectangle", title: "Hakkınızda", subtitle: "Kendinizi ve uzmanlık alanlarınızı tanıtın.", status: .edit)
                                CompletionTaskRow(icon: "briefcase", title: "Deneyim Bilgileri", subtitle: "Çalışma geçmişinizi ve başarılarınızı ekleyin.", status: .add)
                                CompletionTaskRow(icon: "graduationcap", title: "Eğitim Bilgileri", subtitle: "Eğitim geçmişinizi ekleyin.", status: .add)
                                CompletionTaskRow(icon: "star", title: "Yetenekler", subtitle: "Uzmanlık alanlarınızı ve yeteneklerinizi belirtin.", status: .add)
                            }
                        }
                        
                        // Benefit Tip
                        HStack(spacing: 16) {
                            Image(systemName: "person.3.fill")
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Profilinizi tamamlayan kullanıcıların")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                                HStack(spacing: 4) {
                                    Text("%3 kat daha fazla görünür").foregroundColor(.purple).bold()
                                    Text("olduğunu biliyor muydunuz?").foregroundColor(.white)
                                }
                                .font(.system(size: 13))
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(16)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Devam Et")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "6C38FF"))
                            .cornerRadius(12)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .fullScreenCover(isPresented: $showPhotoFlow) {
            ProfilePhotoView()
        }
    }
}

enum TaskStatus {
    case completed, add, edit
}

struct CompletionTaskRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let status: TaskStatus
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    Text(subtitle).font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                if status == .completed {
                    HStack(spacing: 4) {
                        Text("Tamamlandı").font(.system(size: 10, weight: .bold)).foregroundColor(.green)
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)
                } else {
                    Text(status == .add ? "Ekle" : "Düzenle")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
        }
    }
}
