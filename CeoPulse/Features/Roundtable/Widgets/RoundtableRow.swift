import SwiftUI

struct RoundtableRow: View {
    let roundtable: Roundtable
    @StateObject private var viewModel: RoundtableRowViewModel
    
    init(roundtable: Roundtable) {
        self.roundtable = roundtable
        self._viewModel = StateObject(wrappedValue: RoundtableRowViewModel(roundtable: roundtable))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Date Card
            dateCard
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(roundtable.category)
                        .font(.system(size: 10, weight: .bold))
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
                
                // Participants
                participantsView
                
                // Bottom Row: Status and Action
                HStack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        Text(statusText)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(statusColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    actionButton
                }
            }
            .padding(.leading, 16)
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .onAppear {
            Task {
                viewModel.fetchParticipants()
            }
        }
    }
    
    private var dateCard: some View {
        VStack(spacing: 4) {
            Text(dayString)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(monthString)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
            Text(yearString)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.2))
            
            Spacer()
            
            Text(timeString)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(6)
        }
        .frame(width: 70, height: 120)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.02))
        .cornerRadius(16)
    }
    
    private var participantsView: some View {
        HStack(spacing: -8) {
            ForEach(viewModel.participants.prefix(4)) { participant in
                AsyncImage(url: URL(string: "https://i.pravatar.cc/100?u=\(participant.userId)")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "13141C"), lineWidth: 1.5))
                } placeholder: {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 24, height: 24)
                }
            }
            
            if viewModel.participants.count > 4 {
                Text("+\(viewModel.participants.count - 4)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 12)
            }
            
            Text(viewModel.participants.isEmpty ? "Henüz katılımcı yok" : "Ali Yılmaz ve \(viewModel.participants.count) diğer uzman")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 8)
        }
    }
    
    private var actionButton: some View {
        HStack(spacing: 4) {
            Text(roundtable.status == .completed ? "Özeti Gör" : "Masaya Katıl")
            Image(systemName: roundtable.status == .completed ? "doc.text" : "chevron.right")
        }
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(roundtable.status == .completed ? Color.white.opacity(0.1) : Color.purple)
        .cornerRadius(10)
    }
    
    // MARK: - Helpers
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: roundtable.startTime)
    }
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMM"
        return formatter.string(from: roundtable.startTime).uppercased()
    }
    
    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: roundtable.startTime)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: roundtable.startTime)
    }
    
    private var statusText: String {
        switch roundtable.status {
        case .active: return "Devam Ediyor"
        case .upcoming: return "Gelecek"
        case .completed: return "Tamamlandı"
        }
    }
    
    private var statusColor: Color {
        switch roundtable.status {
        case .active: return .green
        case .upcoming: return .blue
        case .completed: return .orange
        }
    }
}
