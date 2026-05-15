import SwiftUI

struct RoundtableView: View {
    @StateObject private var viewModel = RoundtableViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    private let tabs = ["Tüm Masalar", "Kendi Açtıklarım", "Devam Edenler", "Geçmiş Masalar"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Featured Card (Hero)
                if let featured = viewModel.roundtables.first {
                    FeaturedRoundtableCard(roundtable: featured)
                        .padding(.horizontal, 20)
                }
                
                // Tabs
                tabsSection
                
                // Kendi Açtıklarım
                roundtableSection(title: "Kendi Açtıklarım", roundtables: viewModel.roundtables.prefix(1))
                
                // Açılmış Masalar
                roundtableSection(title: "Açılmış Masalar", roundtables: viewModel.roundtables.suffix(3))
                
                // Geçmiş Masalar
                roundtableSection(title: "Geçmiş Masalar", roundtables: viewModel.roundtables.prefix(2), isPast: true)
                
                // Info Section
                infoCardSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var tabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: { selectedTab = index }) {
                        Text(tabs[index])
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(selectedTab == index ? Color.purple : Color.white.opacity(0.05))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func roundtableSection(title: String, roundtables: ArraySlice<Roundtable>, isPast: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Tümünü Gör") { }
                    .font(.system(size: 13))
                    .foregroundColor(.purple)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                ForEach(roundtables) { roundtable in
                    NavigationLink(destination: JoinRoundtableView(roundtable: roundtable)) {
                        RoundtableRow(roundtable: roundtable)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primaryAccent)
                    
                    Text("Yuvarlak Masa")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Fikirler, deneyimler ve vizyonlar buluşuyor.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Button(action: { /* Arama aksiyonu buraya gelecek */ }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
    
    private var infoCardSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryAccent.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: "person.2.fill")
                    .foregroundColor(AppColors.primaryAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Yuvarlak Masa Nedir?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primaryAccent)
                
                Text("Farklı sektörlerden liderler, girişimciler ve uzmanların bir araya geldiği, fikir alışverişinde bulunduğu özel oturumlardır.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(AppColors.surface.opacity(0.3))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
