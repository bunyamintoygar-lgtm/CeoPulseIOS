import SwiftUI

struct RoundtableView: View {
    @StateObject private var viewModel = RoundtableViewModel()
    @Environment(\.dismiss) var dismiss
    
    private let tabs = ["Tüm Masalar", "Kendi Açtıklarım", "Devam Edenler", "Geçmiş Masalar"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky Header & Inline Search
            headerSection
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppColors.background.ignoresSafeArea())
                .zIndex(10)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // Featured Card (Hero) - Only if not searching
                    if let featured = viewModel.roundtables.first, viewModel.searchText.isEmpty && viewModel.selectedCategory == "Tümü" {
                        FeaturedRoundtableCard(roundtable: featured)
                            .padding(.horizontal, 20)
                    }
                    
                    // Tabs (Categories)
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
                .padding(.top, 10)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            Task { await viewModel.refresh() }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            if viewModel.isSearching {
                // Sliding Inline Search Bar with Category Filter
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.4))
                        
                        TextField("Masa başlığı ile ara...", text: $viewModel.searchText)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.none)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        
                        Divider()
                            .frame(height: 20)
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 4)
                        
                        // Category Selector within Search Bar
                        Menu {
                            Button("Tümü") { viewModel.selectedCategory = "Tümü" }
                            ForEach(ConfigManager.shared.roundtableCategories, id: \.id) { category in
                                Button(ConfigManager.shared.getLocalizedValue(category)) {
                                    viewModel.selectedCategory = ConfigManager.shared.getLocalizedValue(category)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: getCategoryIcon(viewModel.selectedCategory))
                                    .font(.system(size: 14))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 8))
                            }
                            .foregroundColor(.purple)
                            .frame(width: 40)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            viewModel.isSearching = false
                            viewModel.searchText = ""
                            viewModel.selectedCategory = "Tümü"
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.purple)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            } else {
                // Normal Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryAccent)
                        
                        Text("Yuvarlak Masa")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Fikirler, deneyimler ve vizyonlar buluşuyor.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.isSearching = true
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .transition(.opacity)
            }
        }
        .frame(height: 50)
    }
    
    private var tabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: { 
                        withAnimation {
                            viewModel.selectedTab = index 
                        }
                    }) {
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
            // Simplified List: All sessions under "Yaklaşan Masalar" (or the selected tab name)
            let headerTitle = viewModel.selectedTab == 0 ? "Yaklaşan Masalar" : tabs[viewModel.selectedTab]
            let displayList = viewModel.selectedTab == 0 ? viewModel.upcomingRoundtables : viewModel.roundtables
            
            roundtableSection(title: headerTitle, roundtables: displayList)
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
                    NavigationLink(destination: destinationView(for: roundtable)) {
                        RoundtableRow(roundtable: roundtable)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func destinationView(for roundtable: Roundtable) -> some View {
        if roundtable.status == .completed {
            RoundtableSummaryView(roundtable: roundtable)
        } else {
            JoinRoundtableView(roundtable: roundtable)
        }
    }
    
    private func getCategoryIcon(_ categoryName: String) -> String {
        if let category = ConfigManager.shared.roundtableCategories.first(where: { ConfigManager.shared.getLocalizedValue($0) == categoryName }) {
            return category.icon ?? "tag.fill"
        }
        return "tag.fill"
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
