import SwiftUI

struct RoundtableView: View {
    @StateObject private var viewModel = RoundtableViewModel()
    
    let categories = [
        ("Tümü", "square.grid.2x2.fill"),
        ("Teknoloji", "cpu"),
        ("Ekonomi", "chart.line.uptrend.xyaxis"),
        ("İK & Organizasyon", "person.3.fill"),
        ("Strateji", "target")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("rt_title".localized())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("rt_subtitle".localized())
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.0) { cat in
                            EventCategoryChip(
                                title: cat.0,
                                iconName: cat.1,
                                isSelected: viewModel.selectedCategory == cat.0
                            ) {
                                viewModel.selectedCategory = cat.0
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Featured Card (Static for now or first active)
                if let featured = viewModel.roundtables.first {
                    FeaturedRoundtableCard(
                        title: featured.title,
                        description: featured.description ?? "",
                        participantCount: 28, // Mock count for now
                        imageName: featured.imageUrl ?? "ai_meeting"
                    )
                    .padding(.horizontal, 20)
                }
                
                // AI Summary Card
                AISummaryCard()
                    .padding(.horizontal, 20)
                
                // Secondary Tabs
                HStack(spacing: 24) {
                    TabItemSmall(title: "rt_tab_my_discussions".localized(), isSelected: viewModel.selectedTab == 0) { viewModel.selectedTab = 0 }
                    TabItemSmall(title: "rt_tab_following".localized(), isSelected: viewModel.selectedTab == 1) { viewModel.selectedTab = 1 }
                    TabItemSmall(title: "rt_tab_completed".localized(), isSelected: viewModel.selectedTab == 2) { viewModel.selectedTab = 2 }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("rt_sort".localized())
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // List
                VStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.purple)
                            .padding()
                    } else if viewModel.roundtables.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Henüz bu kategoride tartışma bulunmuyor.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(viewModel.roundtables) { roundtable in
                            NavigationLink(destination: JoinRoundtableView(roundtable: roundtable)) {
                                RoundtableRow(
                                    title: roundtable.title,
                                    status: roundtable.status.title,
                                    statusColor: roundtable.status.color,
                                    participantCount: 0, // Need to fetch or join
                                    commentCount: 0,
                                    activityText: roundtable.startTime.timeAgoDisplay(),
                                    imageName: roundtable.category.lowercased(),
                                    dateText: roundtable.startTime.formatted(date: .abbreviated, time: .shortened)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Start New Roundtable Button
                startNewRoundtableButton
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var startNewRoundtableButton: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: "person.3.fill")
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("rt_start_new_title".localized())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("rt_start_new_desc".localized())
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text("rt_start_button".localized())
                    Image(systemName: "plus")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppColors.primary)
                .cornerRadius(20)
            }
        }
        .padding(16)
        .background(AppColors.surface.opacity(0.3))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
}

struct TabItemSmall: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                
                if isSelected {
                    Rectangle()
                        .fill(AppColors.primary)
                        .frame(height: 2)
                        .cornerRadius(1)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
    }
}

struct RoundtableView_Previews: PreviewProvider {
    static var previews: some View {
        RoundtableView()
    }
}
