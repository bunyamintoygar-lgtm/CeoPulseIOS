import SwiftUI

struct RoundtableRow: View {
    let roundtable: Roundtable
    
    var body: some View {
        HStack(spacing: 16) {
            // Date Block
            VStack(spacing: 4) {
                Text(roundtable.startTime.formatted(.dateTime.day()))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(roundtable.startTime.formatted(.dateTime.month(.wide)))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(roundtable.startTime.formatted(.dateTime.year()))
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                
                Text(roundtable.startTime.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                
                Text(roundtable.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.primaryAccent)
                    .padding(.top, 4)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
            
            // Content area
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(roundtable.category)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.primaryAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.primaryAccent.opacity(0.1))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Image(systemName: "bookmark")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Text(roundtable.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: -8) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 24, height: 24)
                                .overlay(Circle().stroke(AppColors.background, lineWidth: 1.5))
                        }
                        
                        Text("+12")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color(hex: "2D2F3C"))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppColors.background, lineWidth: 1.5))
                    }
                    
                    Text("Ali Yılmaz ve 15 diğer uzman")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                HStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Detaylar")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(AppColors.surface.opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
