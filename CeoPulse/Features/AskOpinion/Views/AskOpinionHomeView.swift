import SwiftUI

struct AskOpinionHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AskOpinionHomeViewModel()
    @State private var showCreateOpinion = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        heroSection
                        
                        tabSection
                        
                        searchAndFilterSection
                        
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
                                    Task { await viewModel.fetchOpinions() }
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
                    await viewModel.fetchOpinions()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreateOpinion, onDismiss: {
            Task { await viewModel.fetchOpinions() }
        }) {
            AskOpinionView()
        }
        .onAppear {
            Task { await viewModel.fetchOpinions() }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 22))
                Text("Ask Opinion")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 14, height: 14)
                        .overlay(Text("3").font(.system(size: 8, weight: .bold)).foregroundColor(.white))
                        .offset(x: 4, y: -4)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                    Text("PREMIUM")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
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
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Topluluğa Sorun")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Merak ettiğiniz konuyu sorun, uzmanlar ve liderlerden farklı bakış açıları kazanın.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: 200, alignment: .leading)
                    
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
                        .background(Color(hex: "6D28D9")) // Deep Purple
                        .cornerRadius(14)
                    }
                    .padding(.top, 8)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 10))
                        Text("Sorularınız topluluğumuzda yayınlanır ve ilgili kişiler tarafından yanıtlanır.")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 4)
                }
                
                Spacer()
                
                // 3D Illustration placeholder
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple.opacity(0.8))
                        .offset(x: 10, y: -10)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.purple.opacity(0.4))
                        .offset(x: -20, y: 20)
                }
                .padding(.trailing, 10)
            }
            .padding(24)
        }
        .padding(.horizontal, 20)
    }
    
    private var tabSection: some View {
        HStack(spacing: 0) {
            tabButton(title: "Tüm Sorular", index: 0)
            tabButton(title: "Yanıtladıklarım", index: 1)
            tabButton(title: "Takip Ettiklerim", index: 2)
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
    
    private var searchAndFilterSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Sorularda ara...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease")
                    Text("Filtrele")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var opinionList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredOpinions) { opinion in
                OpinionCard(opinion: opinion)
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
