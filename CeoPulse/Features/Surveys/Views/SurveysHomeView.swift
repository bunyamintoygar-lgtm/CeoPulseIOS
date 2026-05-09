import SwiftUI

struct SurveysHomeView: View {
    @State private var selectedTab = "Aktif Anketler"
    @State private var searchText = ""
    @State private var showCreateSurvey = false
    @Namespace private var animationNamespace
    
    @StateObject private var viewModel = SurveyViewModel()
    @State private var selectedSurvey: Survey?
    @State private var selectedResultsSurvey: Survey?
    @State private var shareURL: URL?
    @State private var showShareSheet = false
    @State private var isSearchVisible = false
    @State private var showingFilterMenu = false
    
    let tabs = ["Aktif Anketler", "Tamamlananlar", "Taslaklarım", "Arşiv"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Anketler")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.purple)
                                Text("Görüşünüz, geleceği şekillendirir.")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: { withAnimation(.spring()) { isSearchVisible.toggle() } }) {
                                ZStack {
                                    Circle().fill(Color.white.opacity(0.05)).frame(width: 44, height: 44)
                                    Image(systemName: isSearchVisible ? "xmark" : "magnifyingglass")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Image("ceo_profile_1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.purple.opacity(0.3), lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Search and Filter Bar
                    if isSearchVisible {
                        HStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 14, weight: .bold))
                                
                                TextField("Anket ara...", text: Binding(
                                    get: { viewModel.searchQuery },
                                    set: { viewModel.updateSearchQuery($0) }
                                ))
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                
                                if !viewModel.searchQuery.isEmpty {
                                    Button(action: { viewModel.updateSearchQuery("") }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            
                            // Filter Button
                            Menu {
                                Button(action: { viewModel.updateCategoryFilter(nil) }) {
                                    Label("Tüm Kategoriler", systemImage: viewModel.selectedCategoryId == nil ? "checkmark.circle.fill" : "circle")
                                }
                                
                                Divider()
                                
                                ForEach(ConfigManager.shared.surveyCategories) { category in
                                    Button(action: { viewModel.updateCategoryFilter(category.id) }) {
                                        Label(category.name, systemImage: viewModel.selectedCategoryId == category.id ? "checkmark.circle.fill" : (category.icon ?? "tag"))
                                    }
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.selectedCategoryId != nil ? Color.purple.opacity(0.2) : Color.white.opacity(0.05))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.selectedCategoryId != nil ? .purple : .white)
                                }
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(viewModel.selectedCategoryId != nil ? Color.purple.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(tabs, id: \.self) { tab in
                                SurveyTabButton(title: tab, isSelected: selectedTab == tab, animationNamespace: animationNamespace) {
                                    withAnimation {
                                        selectedTab = tab
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.purple)
                                    .padding(.top, 40)
                            } else if let error = viewModel.errorMessage {
                                errorView(error)
                            } else {
                                if selectedTab == "Aktif Anketler" {
                                    activeSurveysList
                                } else if selectedTab == "Tamamlananlar" {
                                    completedSurveysList
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    .onAppear {
                        viewModel.fetchSurveys()
                    }
                    .refreshable {
                        viewModel.fetchSurveys()
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showCreateSurvey = true }) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.purple, Color(hex: "6C38FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 52, height: 52)
                                    .shadow(color: Color.purple.opacity(0.4), radius: 10, y: 5)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .symbolEffect(.bounce, options: .repeating, value: showCreateSurvey)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateSurvey) {
                CreateSurveyView(onPublish: {
                    viewModel.fetchSurveys()
                })
            }
            .sheet(item: $selectedSurvey) { survey in
                JoinSurveyView(survey: survey)
            }
            .sheet(item: $selectedResultsSurvey) { survey in
                SurveyResultsView(survey: survey)
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    private var activeSurveysList: some View {
        VStack(spacing: 20) {
            if viewModel.activeSurveys.isEmpty {
                emptyStateView(title: "Aktif anket bulunamadı")
            } else {
                ForEach(viewModel.activeSurveys) { survey in
                    let isExpired = survey.endDate != nil && survey.endDate! < Date()
                    let stats = viewModel.surveyStats[survey.id]
                    let hasVoted = stats?.hasVoted ?? false
                    
                    SurveyCard(
                        survey: survey,
                        totalVotes: stats?.totalVotes ?? 0, 
                        participationRate: stats?.totalVotes != nil ? Double(min(stats!.totalVotes * 7, 100)) / 100.0 : 0.0, // Dynamic but simulated rate
                        timeRemaining: survey.endDate?.timeRemaining() ?? "Süresiz",
                        isAnonymous: survey.isAnonymous,
                        buttonTitle: isExpired || hasVoted ? "Sonuçları Gör" : "Ankete Katıl",
                        onJoin: {
                            if isExpired || hasVoted {
                                selectedResultsSurvey = survey
                            } else {
                                selectedSurvey = survey
                            }
                        }
                    )
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentSurvey: survey)
                    }
                }
            }
            
            // Privacy Note
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                    Image(systemName: "shield.checkered")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Güvenli ve Anonim")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Görüşlerinizi güvenle paylaşabilirsiniz.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.purple)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.03)))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
    
    private var completedSurveysList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tamamlanan Anketler")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if !viewModel.completedSurveys.isEmpty {
                    Text("\(viewModel.completedSurveys.count)")
                        .font(.system(size: 13))
                        .foregroundColor(.purple)
                }
            }
            
            if viewModel.completedSurveys.isEmpty && !viewModel.isLoading {
                Text("Henüz tamamlanmış bir anket bulunmuyor.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 10)
            } else {
                ForEach(viewModel.completedSurveys) { survey in
                    NavigationLink(destination: SurveyResultsView(survey: survey)) {
                        SurveyCompletedRow(
                            title: survey.title,
                            date: survey.endDate?.formatted(date: .abbreviated, time: .omitted) ?? "Tamamlandı",
                            rate: 100,
                            icon: "chart.bar.fill",
                            color: .purple
                        )
                    }
                }
            }
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button("Tekrar Dene") {
                viewModel.fetchSurveys()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Capsule().fill(Color.purple))
            .foregroundColor(.white)
        }
        .padding(.top, 60)
    }
    
    private func emptyStateView(title: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 32))
                    .foregroundColor(.purple.opacity(0.5))
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.top, 60)
    }
}

struct SurveyTabButton: View {
    let title: String
    let isSelected: Bool
    var animationNamespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(Color.purple.opacity(0.15))
                                .matchedGeometryEffect(id: "tab", in: animationNamespace)
                        } else {
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                        }
                    }
                )
                .foregroundColor(isSelected ? .purple : AppColors.textSecondary)
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
