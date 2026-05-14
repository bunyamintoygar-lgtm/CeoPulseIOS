import SwiftUI

struct AskOpinionHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AskOpinionHomeViewModel()
    @State private var showCreateOpinion = false
    @State private var isFilterSheetPresented = false
    @State private var isSearchExpanded = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        heroSection
                        
                        tabSection
                        
                        if viewModel.isLoading && viewModel.opinions.isEmpty {
                            VStack {
                                Spacer()
                                ProgressView()
                                    .tint(.purple)
                                    .scaleEffect(1.5)
                                Text("Sorular yükleniyor...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                                Spacer()
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                Text(error)
                                    .foregroundColor(.white)
                                Button("Tekrar Dene") {
                                    Task { await viewModel.refreshOpinions() }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(10)
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                        } else if viewModel.filteredOpinions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text(viewModel.searchText.isEmpty ? "Henüz hiç soru sorulmamış." : "Aramanızla eşleşen soru bulunamadı.")
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 40)
                        } else {
                            opinionList
                        }
                        
                        footerSection
                    }
                    .padding(.top, 10)
                }
                .refreshable {
                    await viewModel.refreshOpinions()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreateOpinion, onDismiss: {
            Task { await viewModel.refreshOpinions() }
        }) {
            AskOpinionView()
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            categorySelectionSheet
        }
        .onAppear {
            Task { await viewModel.refreshOpinions() }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack(spacing: 12) {
            if isSearchExpanded {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Sorularda ara...", text: $viewModel.searchText)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .focused($isSearchFocused)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    
                    Button(action: { isFilterSheetPresented = true }) {
                        let selectedCategory = ConfigManager.shared.opinionCategories.first(where: { $0.id == viewModel.selectedCategory })
                        Image(systemName: selectedCategory?.icon ?? (viewModel.selectedCategory == nil ? "line.3.horizontal.decrease" : "line.3.horizontal.decrease.circle.fill"))
                            .foregroundColor(viewModel.selectedCategory == nil ? .white : .purple)
                            .font(.system(size: 18))
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    
                    Button(action: {
                        withAnimation {
                            isSearchExpanded = false
                            isSearchFocused = false
                            viewModel.searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 22))
                    Text("Ask Opinion")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isSearchExpanded = true
                        isSearchFocused = true
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var heroSection: some View {
        ZStack(alignment: .leading) {
            // Background Gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [Color(hex: "2A1B54"), Color(hex: "120C28")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Topluluğa Sorun")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Merak ettiğiniz konuyu sorun, uzmanlar ve liderlerden farklı bakış açıları kazanın.")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.trailing, 10)
                        
                        Button(action: {
                            showCreateOpinion = true
                        }) {
                            HStack {
                                Text("Yeni Soru Sor")
                                Image(systemName: "plus.circle")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(hex: "6D28D9"))
                            .cornerRadius(14)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 10)
                    
                    // Animated SF Symbols 3D Illustration
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow.opacity(0.8))
                            .offset(x: -35, y: -35)
                            .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeating)
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 65))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.purple.opacity(0.9), .blue.opacity(0.6))
                            .offset(x: 5, y: -10)
                            .symbolEffect(.breathe, options: .repeating) // iOS 18 Özel
                        
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "F59E0B")) // Amber
                            .offset(x: 35, y: 20)
                            .symbolEffect(.wiggle, options: .repeating) // iOS 18 Özel
                    }
                    .offset(y: -10)
                }
                
                // Bottom Text Box 100% Width
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .padding(.top, 1)
                    Text("Sorularınız topluluğumuzda yayınlanır ve ilgili kişiler tarafından yanıtlanır.")
                        .font(.system(size: 11))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.white.opacity(0.5))
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
            .padding(24)
        }
        .padding(.horizontal, 20)
    }
    
    private var tabSection: some View {
        HStack(spacing: 0) {
            tabButton(title: "Tüm Sorular", index: 0)
            tabButton(title: "Yanıtladıklarım", index: 1)
            tabButton(title: "Sorularım", index: 2)
        }
        .padding(4)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation { viewModel.selectedTab = index }
        }) {
            Text(title)
                .font(.system(size: 12, weight: viewModel.selectedTab == index ? .bold : .medium))
                .foregroundColor(viewModel.selectedTab == index ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(viewModel.selectedTab == index ? Color.white.opacity(0.1) : Color.clear)
                .cornerRadius(10)
        }
    }
    
    
    private var categorySelectionSheet: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        // All Categories Option
                        Button(action: {
                            viewModel.selectCategory(nil)
                            isFilterSheetPresented = false
                        }) {
                            HStack {
                                Image(systemName: "square.grid.2x2.fill")
                                    .foregroundColor(.purple)
                                    .frame(width: 30)
                                Text("Tüm Kategoriler")
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedCategory == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.purple)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.vertical, 8)
                        
                        // Dynamic Categories
                        ForEach(ConfigManager.shared.opinionCategories, id: \.id) { category in
                            Button(action: {
                                viewModel.selectCategory(category.id)
                                isFilterSheetPresented = false
                            }) {
                                HStack {
                                    Image(systemName: category.icon ?? "tag.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 30)
                                    Text(category.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if viewModel.selectedCategory == category.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.purple)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Kategori Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { isFilterSheetPresented = false }
                        .foregroundColor(.purple)
                }
            }
        }
    }
    
    private var opinionList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredOpinions) { opinion in
                OpinionCard(opinion: opinion)
                    .onAppear {
                        Task {
                            await viewModel.fetchMoreOpinionsIfNeeded(currentOpinion: opinion)
                        }
                    }
            }
            
            if viewModel.isFetchingMore {
                ProgressView()
                    .tint(.purple)
                    .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var footerSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: "star.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Kaliteli ve yapıcı yanıtlar vererek topluluğa katkıda bulunun.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                Text("Katkılarınız profilinizde öne çıkar.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

struct AskOpinionHomeView_Previews: PreviewProvider {
    static var previews: some View {
        AskOpinionHomeView()
    }
}
