import SwiftUI

struct SurveysHomeView: View {
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
    
    @State private var surveyToDelete: Survey?
    @State private var showingDeleteAlert = false
    @State private var surveyToEdit: Survey?
    
    // AI Rejection Popup States
    @State private var showingRejectionPopup = false
    @State private var surveyWithRejection: Survey?
    
    struct TabItem: Hashable {
        let id: String
        let title: String
    }
    
    var tabs: [TabItem] {
        [
            TabItem(id: "discovery", title: NSLocalizedString("survey_tab_discovery", comment: "")),
            TabItem(id: "active", title: NSLocalizedString("survey_tab_active", comment: "")),
            TabItem(id: "completed", title: NSLocalizedString("survey_tab_completed", comment: "")),
            TabItem(id: "my_surveys", title: NSLocalizedString("survey_tab_my_surveys", comment: "")),
            TabItem(id: "archive", title: NSLocalizedString("survey_tab_archive", comment: ""))
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey("survey_title"))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.purple)
                                Text(LocalizedStringKey("survey_subtitle"))
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: { 
                                withAnimation(.spring()) { 
                                    isSearchVisible.toggle()
                                    if !isSearchVisible {
                                        viewModel.updateSearchQuery("")
                                    }
                                } 
                            }) {
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
                                
                                TextField(LocalizedStringKey("ao_field_title_placeholder"), text: Binding(
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
                                    Label(LocalizedStringKey("events_category_all"), systemImage: viewModel.selectedCategoryId == nil ? "checkmark.circle.fill" : "circle")
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
                                    
                                    let selectedCategory = ConfigManager.shared.surveyCategories.first(where: { $0.id == viewModel.selectedCategoryId })
                                    Image(systemName: selectedCategory?.icon ?? "line.3.horizontal.decrease.circle")
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
                            ForEach(tabs, id: \.id) { tab in
                                SurveyTabButton(title: tab.title, isSelected: viewModel.selectedTab == tab.id, animationNamespace: animationNamespace) {
                                    viewModel.updateSelectedTab(tab.id)
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
                                Group {
                                    switch viewModel.selectedTab {
                                    case "discovery":
                                        discoveryDashboard
                                    case "active":
                                        activeSurveysList
                                    case "completed":
                                        completedSurveysList
                                    case "my_surveys":
                                        mySurveysList
                                    case "archive":
                                        archiveSurveysList
                                    default:
                                        emptyStateView(title: String(format: NSLocalizedString("ao_step3", comment: ""), viewModel.selectedTab))
                                    }
                                }
                                .id(viewModel.selectedTab)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    .onAppear {
                        if ConfigManager.shared.surveyCategories.isEmpty {
                            Task { await ConfigManager.shared.fetchConfigs() }
                        }
                    }
                    .refreshable {
                        viewModel.refreshAll()
                        Task { await ConfigManager.shared.fetchConfigs() }
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
                
                // Custom Delete Confirmation Overlay
                if showingDeleteAlert, let survey = surveyToDelete {
                    ZStack {
                        Color.black.opacity(0.8).ignoresSafeArea()
                            .onTapGesture { 
                                withAnimation { showingDeleteAlert = false }
                            }
                        
                        VStack(spacing: 24) {
                            // Warning Icon
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.red)
                                    .symbolEffect(.bounce, options: .repeating)
                            }
                            
                            VStack(spacing: 12) {
                                Text(LocalizedStringKey("survey_delete_confirm_title"))
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(String(format: NSLocalizedString("survey_delete_confirm_desc", comment: ""), survey.title))
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            VStack(spacing: 12) {
                                Button(action: {
                                    viewModel.deleteSurvey(survey)
                                    withAnimation { showingDeleteAlert = false }
                                }) {
                                    Text(LocalizedStringKey("survey_delete_confirm_title"))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                        .background(Color.red)
                                        .cornerRadius(16)
                                        .shadow(color: Color.red.opacity(0.3), radius: 10, y: 5)
                                }
                                
                                Button(action: { 
                                    withAnimation { showingDeleteAlert = false }
                                }) {
                                    Text(LocalizedStringKey("survey_create_cancel"))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color(hex: "121217"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 30)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    }
                    .zIndex(100)
                }
                
                if showingRejectionPopup, let survey = surveyWithRejection {
                    rejectionPopup(for: survey)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateSurvey) {
                CreateSurveyView(onPublish: {
                    viewModel.refreshAll()
                })
            }
            .sheet(item: $surveyToEdit) { survey in
                CreateSurveyView(onPublish: {
                    viewModel.refreshAll()
                    surveyToEdit = nil
                }, surveyToEdit: survey)
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
    
    private func rejectionPopup(for survey: Survey) -> some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showingRejectionPopup = false }
                }
            
            VStack(spacing: 24) {
                rejectionHeaderView
                
                rejectionReasonBox(reason: survey.rejectionReason)
                
                // Close Button
                Button(action: {
                    withAnimation { showingRejectionPopup = false }
                }) {
                    Text(LocalizedStringKey("survey_rejection_button"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(hex: "1A1A23"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }

    private var rejectionHeaderView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text(LocalizedStringKey("survey_rejection_title"))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("survey_rejection_desc"))
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private func rejectionReasonBox(reason: String?) -> some View {
        let displayReason: String = {
            guard let reason = reason else {
                return NSLocalizedString("survey_rejection_default_reason", comment: "")
            }
            
            // Eski JSON formatı için fallback desteği (Opsiyonel)
            if reason.starts(with: "{"),
               let data = reason.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                let languageCode = Locale.current.language.languageCode?.identifier ?? "tr"
                return json[languageCode] ?? json["en"] ?? json["tr"] ?? reason
            }
            
            return reason
        }()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("survey_rejection_reason_label"))
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.orange.opacity(0.8))
                .kerning(1.2)
            
            Text(displayReason)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var activeSurveysList: some View {
        VStack(spacing: 20) {
            if viewModel.activeSurveysList.isEmpty {
                emptyStateView(title: NSLocalizedString("rt_status_upcoming", comment: ""))
            } else {
                ForEach(viewModel.activeSurveysList) { survey in
                    let stats = viewModel.surveyStats[survey.id]
                    let hasVoted = stats?.hasVoted ?? false
                    let totalVotes = stats?.totalVotes ?? 0
                    let isExpired = survey.endDate != nil && survey.endDate! < Date()
                    let isCreator = survey.creatorId == viewModel.currentUserId
                    
                    SurveyCard(
                        survey: survey,
                        totalVotes: totalVotes, 
                        participationRate: Double(totalVotes) / Double(max(viewModel.totalUserCount, 1)),
                        timeRemaining: survey.endDate?.timeRemaining() ?? NSLocalizedString("rt_status_active", comment: ""),
                        isAnonymous: survey.isAnonymous,
                        buttonTitle: isExpired || hasVoted ? NSLocalizedString("rt_view_summary", comment: "") : NSLocalizedString("survey_join_button", comment: ""),
                        onJoin: {
                            if survey.status == .rejected {
                                withAnimation(.spring()) {
                                    surveyWithRejection = survey
                                    showingRejectionPopup = true
                                }
                            } else if isExpired || hasVoted {
                                selectedResultsSurvey = survey
                            } else {
                                selectedSurvey = survey
                            }
                        },
                        onEdit: (isCreator && totalVotes == 0) ? {
                            surveyToEdit = survey
                        } : nil,
                        onDelete: (isCreator && totalVotes == 0) ? {
                            surveyToDelete = survey
                            withAnimation(.spring()) {
                                showingDeleteAlert = true
                            }
                        } : nil
                    )
                    .onAppear {
                        if let tabKey = ["active", "completed", "my_surveys", "archive"].first(where: { viewModel.selectedTab == $0 }) {
                            viewModel.loadMoreIfNeeded(currentSurvey: survey, forTab: tabKey)
                        } else {
                            viewModel.loadMoreIfNeeded(currentSurvey: survey, forTab: "discovery") // fallback
                        }
                    }
                }
                
                if viewModel.isFetchingMore {
                    ProgressView()
                        .tint(.purple)
                        .padding(.vertical, 10)
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
                        Text(LocalizedStringKey("rt_before_2_title"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        Text(LocalizedStringKey("survey_privacy_info"))
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
                Text(LocalizedStringKey("survey_completed_title"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if !viewModel.completedSurveysList.isEmpty {
                    Text("\(viewModel.completedSurveysList.count)")
                        .font(.system(size: 13))
                        .foregroundColor(.purple)
                }
            }
            
            if viewModel.completedSurveysList.isEmpty && !viewModel.isLoading {
                    Text(LocalizedStringKey("rt_tab_completed"))
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 10)
            } else {
                ForEach(viewModel.completedSurveysList) { survey in
                    NavigationLink(destination: SurveyResultsView(survey: survey)) {
                        SurveyCompletedRow(
                            title: survey.title,
                            date: survey.endDate?.formatted(date: .abbreviated, time: .omitted) ?? NSLocalizedString("survey_completed_status", comment: ""),
                            rate: 100,
                            icon: "chart.bar.fill",
                            color: .purple
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if let tabKey = ["active", "completed", "my_surveys", "archive"].first(where: { viewModel.selectedTab == $0 }) {
                            viewModel.loadMoreIfNeeded(currentSurvey: survey, forTab: tabKey)
                        } else {
                            viewModel.loadMoreIfNeeded(currentSurvey: survey, forTab: "discovery") // fallback
                        }
                    }
                }
                
                if viewModel.isFetchingMore {
                    HStack {
                        Spacer()
                        ProgressView().tint(.purple)
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
            }
        }
    }
    
    private var discoveryDashboard: some View {
        VStack(spacing: 32) {
            // 1. Discovery Section (Not voted, Active/Archived mix)
            let discoverySurveys = viewModel.activeSurveysList.prefix(4)
            if !discoverySurveys.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey("survey_tab_discovery"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    // The Hero Card (First one)
                    if let firstSurvey = discoverySurveys.first {
                        let stats = viewModel.surveyStats[firstSurvey.id]
                        let totalVotes = stats?.totalVotes ?? 0
                        
                        SurveyCard(
                            survey: firstSurvey,
                            totalVotes: totalVotes,
                            participationRate: Double(totalVotes) / Double(max(viewModel.totalUserCount, 1)),
                            timeRemaining: firstSurvey.endDate?.timeRemaining() ?? NSLocalizedString("rt_status_active", comment: ""),
                            isAnonymous: firstSurvey.isAnonymous,
                            buttonTitle: NSLocalizedString("survey_join_button", comment: ""),
                            onJoin: { selectedSurvey = firstSurvey }
                        )
                    }
                    
                    // The List Rows (Next 3)
                    let remainingSurveys = discoverySurveys.dropFirst()
                    if !remainingSurveys.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(remainingSurveys) { survey in
                                let stats = viewModel.surveyStats[survey.id]
                                let totalVotes = stats?.totalVotes ?? 0
                                let participationRate = totalVotes > 0 ? Int((Double(totalVotes) / Double(max(viewModel.totalUserCount, 1))) * 100) : 0
                                
                                Button(action: { selectedSurvey = survey }) {
                                    SurveyCompletedRow(
                                        title: survey.title,
                                        date: survey.endDate?.timeRemaining() ?? NSLocalizedString("rt_status_active", comment: ""),
                                        rate: participationRate,
                                        icon: ConfigManager.shared.surveyCategories.first(where: { $0.id == survey.categoryId })?.icon ?? "sparkles",
                                        color: .purple
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            
            // 2. Recent My Surveys (Creator is me)
            let myRecentSurveys = viewModel.mySurveysList.prefix(3)
            if !myRecentSurveys.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(LocalizedStringKey("survey_tab_my_surveys"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { withAnimation { viewModel.updateSelectedTab("my_surveys") } }) {
                            Text(LocalizedStringKey("survey_see_all"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.purple)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(myRecentSurveys) { survey in
                            let stats = viewModel.surveyStats[survey.id]
                            let totalVotes = stats?.totalVotes ?? 0
                            let participationRate = totalVotes > 0 ? Int((Double(totalVotes) / Double(max(viewModel.totalUserCount, 1))) * 100) : 0
                            
                            Button(action: { selectedResultsSurvey = survey }) {
                                SurveyCompletedRow(
                                    title: survey.title,
                                    date: survey.createdAt.timeAgoDisplay(),
                                    rate: participationRate,
                                    icon: ConfigManager.shared.surveyCategories.first(where: { $0.id == survey.categoryId })?.icon ?? "person.circle",
                                    color: .blue
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            
            // 3. Completed Surveys (Voted, List Style)
            let completedRecent = viewModel.completedSurveysList.prefix(5)
            if !completedRecent.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(LocalizedStringKey("survey_tab_completed"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { withAnimation { viewModel.updateSelectedTab("completed") } }) {
                            Text(LocalizedStringKey("survey_see_all"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.purple)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(completedRecent) { survey in
                            let stats = viewModel.surveyStats[survey.id]
                            let totalVotes = stats?.totalVotes ?? 0
                            let participationRate = totalVotes > 0 ? Int((Double(totalVotes) / Double(max(viewModel.totalUserCount, 1))) * 100) : 0
                            
                            Button(action: { selectedResultsSurvey = survey }) {
                                SurveyCompletedRow(
                                    title: survey.title,
                                    date: survey.endDate?.formatted(.dateTime.month().year()) ?? NSLocalizedString("rt_status_active", comment: ""),
                                    rate: participationRate,
                                    icon: ConfigManager.shared.surveyCategories.first(where: { $0.id == survey.categoryId })?.icon ?? "chart.bar.fill",
                                    color: .purple
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            
            if discoverySurveys.isEmpty && myRecentSurveys.isEmpty && completedRecent.isEmpty {
                emptyStateView(title: NSLocalizedString("rt_status_upcoming", comment: ""))
            }
        }
    }
    
    private var archiveSurveysList: some View {
        VStack(spacing: 20) {
            if viewModel.archivedSurveysList.isEmpty {
                emptyStateView(title: NSLocalizedString("rt_status_archived", comment: ""))
            } else {
                ForEach(viewModel.archivedSurveysList) { survey in
                    let stats = viewModel.surveyStats[survey.id]
                    let totalVotes = stats?.totalVotes ?? 0
                    
                    SurveyCard(
                        survey: survey,
                        totalVotes: totalVotes,
                        participationRate: Double(totalVotes) / Double(max(viewModel.totalUserCount, 1)),
                        timeRemaining: NSLocalizedString("rt_status_archived", comment: ""),
                        isAnonymous: survey.isAnonymous,
                        buttonTitle: NSLocalizedString("rt_view_summary", comment: ""),
                        onJoin: { selectedResultsSurvey = survey }
                    )
                }
            }
        }
    }
    
    private var mySurveysList: some View {
        VStack(spacing: 20) {
            if viewModel.mySurveysList.isEmpty {
                emptyStateView(title: NSLocalizedString("rt_tab_my_discussions", comment: ""))
            } else {
                ForEach(viewModel.mySurveysList) { survey in
                    let stats = viewModel.surveyStats[survey.id]
                    let totalVotes = stats?.totalVotes ?? 0
                    let isCreator = survey.creatorId == viewModel.currentUserId
                    
                    SurveyCard(
                        survey: survey,
                        totalVotes: totalVotes,
                        participationRate: Double(totalVotes) / Double(max(viewModel.totalUserCount, 1)),
                        timeRemaining: survey.endDate?.timeRemaining() ?? NSLocalizedString("rt_status_active", comment: ""),
                        isAnonymous: survey.isAnonymous,
                        buttonTitle: NSLocalizedString("events_see_details", comment: ""),
                        onJoin: {
                            if survey.status == .rejected {
                                withAnimation(.spring()) {
                                    surveyWithRejection = survey
                                    showingRejectionPopup = true
                                }
                            } else {
                                selectedResultsSurvey = survey
                            }
                        },
                        onEdit: (isCreator && totalVotes == 0) ? {
                            surveyToEdit = survey
                        } : nil,
                        onDelete: (isCreator && totalVotes == 0) ? {
                            surveyToDelete = survey
                            withAnimation(.spring()) {
                                showingDeleteAlert = true
                            }
                        } : nil
                    )
                    .onAppear {
                        if let tabKey = ["active", "completed", "my_surveys", "archive"].first(where: { viewModel.selectedTab == $0 }) {
                            viewModel.loadMoreIfNeeded(currentSurvey: survey, forTab: tabKey)
                        } else {
                            viewModel.loadMoreIfNeeded(currentSurvey: survey, forTab: "discovery") // fallback
                        }
                    }
                }
                
                if viewModel.isFetchingMore {
                    ProgressView().tint(.purple).padding(.vertical, 10)
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
            
            Button(action: { viewModel.refreshAll() }) {
                Text(LocalizedStringKey("common_retry"))
                    .font(.system(size: 15, weight: .bold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.purple))
                    .foregroundColor(.white)
            }
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
