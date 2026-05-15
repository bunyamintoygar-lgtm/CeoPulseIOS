import SwiftUI

struct RoundtableView: View {
    @StateObject private var viewModel = RoundtableViewModel()
    @Environment(\.dismiss) var dismiss
    
    private let tabs = ["Tüm Masalar", "Kendi Açtıklarım", "Devam Edenler", "Geçmiş Masalar"]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Search Bar (Conditional)
                if viewModel.isSearching {
                    searchBarSection
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Featured Card (Hero)
                if let featured = viewModel.roundtables.first, viewModel.searchText.isEmpty {
                    FeaturedRoundtableCard(roundtable: featured)
                        .padding(.horizontal, 20)
                }
                
                // Tabs
                tabsSection
                
                // Content based on selected tab or search
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if viewModel.roundtables.isEmpty {
                    emptyStateSection
                } else {
                    mainContentSection
                }
                
                // Info Section
                infoCardSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .animation(.spring(), value: viewModel.isSearching)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var searchBarSection: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.4))
                TextField("Masa başlığı ile ara...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            Button("İptal") {
                viewModel.isSearching = false
                viewModel.searchText = ""
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.purple)
        }
    }
    
    private var tabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: { viewModel.selectedTab = index }) {
                        Text(tabs[index])
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(viewModel.selectedTab == index ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedTab == index ? Color.purple : Color.white.opacity(0.05))
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
    
    private var mainContentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            if viewModel.selectedTab == 0 && viewModel.searchText.isEmpty {
                // Sectioned view for "Tüm Masalar"
                roundtableSection(title: "Öne Çıkanlar", roundtables: Array(viewModel.roundtables.prefix(2)))
                roundtableSection(title: "Tüm Masalar", roundtables: viewModel.roundtables)
            } else {
                // List view for specific tabs or search
                roundtableSection(title: tabs[viewModel.selectedTab], roundtables: viewModel.roundtables)
            }
        }
    }
    
    private func roundtableSection(title: String, roundtables: [Roundtable]) -> some View {
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
    
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))
            Text("Sonuç bulunamadı")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text("Farklı bir arama yapmayı veya filtreleri değiştirmeyi deneyin.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 40)
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
            
            Button(action: { 
                withAnimation {
                    viewModel.isSearching.toggle()
                }
            }) {
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
