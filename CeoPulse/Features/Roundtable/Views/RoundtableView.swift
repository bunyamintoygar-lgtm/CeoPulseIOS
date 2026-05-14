import SwiftUI

struct RoundtableView: View {
    @StateObject private var viewModel = RoundtableViewModel()
    @Environment(\.dismiss) var dismiss
    
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
                
                // Upcoming Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Yaklaşan Yuvarlak Masalar")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button("Tümünü Gör") { }
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView().tint(AppColors.primaryAccent)
                        } else {
                            ForEach(viewModel.roundtables.prefix(3)) { roundtable in
                                NavigationLink(destination: JoinRoundtableView(roundtable: roundtable)) {
                                    RoundtableRow(roundtable: roundtable)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Past Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Geçmiş Yuvarlak Masalar")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button("Tümünü Gör") { }
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            PastRoundtableCard(
                                title: "Yeni Nesil Liderlik Anlayışı",
                                date: "18 Mayıs 2025",
                                category: "Liderlik",
                                duration: "01:25:30",
                                imageName: "past_1"
                            )
                            
                            PastRoundtableCard(
                                title: "Dijital Dönüşümde Başarı",
                                date: "11 Mayıs 2025",
                                category: "İnovasyon",
                                duration: "01:12:45",
                                imageName: "past_2"
                            )
                            
                            PastRoundtableCard(
                                title: "Piyasa Trendleri ve Tahminler",
                                date: "4 Mayıs 2025",
                                category: "Finans",
                                duration: "01:08:12",
                                imageName: "past_3"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
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
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
            }
            
            VStack(spacing: 4) {
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
