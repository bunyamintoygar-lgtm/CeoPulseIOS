import SwiftUI

struct RoundtableRow: View {
    let roundtable: Roundtable
    @StateObject private var viewModel: RoundtableRowViewModel
    
    init(roundtable: Roundtable) {
        self.roundtable = roundtable
        self._viewModel = StateObject(wrappedValue: RoundtableRowViewModel(roundtableId: roundtable.id))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            dateBlock
            contentSection
        }
        .padding(12)
        .background(AppColors.surface.opacity(0.4))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .onAppear {
            viewModel.fetchParticipants()
        }
    }
    
    private var dateBlock: some View {
        VStack(spacing: 4) {
            Text(roundtable.startTime.formatted(.dateTime.day()))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(roundtable.startTime.formatted(.dateTime.month()))
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            
            Text(roundtable.startTime.formatted(.dateTime.year()))
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
            
            Text(roundtable.startTime.formatted(.dateTime.weekday()))
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
            
            Text(roundtable.startTime.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
                .padding(.top, 4)
        }
        .frame(width: 85)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.02))
        .cornerRadius(16)
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(roundtable.category)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
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
                .multilineTextAlignment(.leading)
            
            participantsSection
            
            HStack {
                statusBadge
                Spacer()
                actionButton
            }
        }
    }
    
    private var participantsSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: -8) {
                let displayCount = min(viewModel.participants.count, 4)
                ForEach(0..<displayCount, id: \.self) { index in
                    let p = viewModel.participants[index]
                    AsyncImage(url: URL(string: p.avatar_url ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.background, lineWidth: 1.5))
                }
                
                if viewModel.participants.count > 4 {
                    Text("+\(viewModel.participants.count - 4)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color(hex: "2D2F3C"))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.background, lineWidth: 1.5))
                }
            }
            
            Text("\(viewModel.participants.first?.fullName ?? "Katılımcı") ve \(max(viewModel.participants.count - 1, 0)) diğer uzman")
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            if roundtable.status == .active {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text("Devam Ediyor")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.gray)
                Text("Tamamlandı")
            }
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundColor(roundtable.status == .active ? .green : .gray)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(roundtable.status == .active ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
        .cornerRadius(20)
    }
    
    private var actionButton: some View {
        HStack(spacing: 4) {
            Text(actionButtonTitle)
            Image(systemName: "chevron.right")
        }
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
    
    private var actionButtonTitle: String {
        if roundtable.status == .active {
            // Using moderatorId for checking ownership
            return roundtable.moderatorId == UUID() /* CurrentUser placeholder */ ? "Masaya Git" : "Masaya Katıl"
        } else {
            return "Özeti Gör"
        }
    }
}
