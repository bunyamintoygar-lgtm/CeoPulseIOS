import SwiftUI

struct LocationSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedLocation: String? = "İstanbul, Türkiye"
    
    let suggestedLocations = [
        "Ankara, Türkiye",
        "İzmir, Türkiye",
        "Bursa, Türkiye",
        "Antalya, Türkiye"
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Title Section
                        VStack(spacing: 12) {
                            Text(NSLocalizedString("location_title", comment: ""))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text(NSLocalizedString("location_subtitle", comment: ""))
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Search Bar
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary)
                            TextField("", text: $searchText, prompt: Text(NSLocalizedString("location_search_placeholder", comment: "")).foregroundColor(AppColors.textSecondary))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        
                        // Current Location Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("location_current_title", comment: ""))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Button(action: { /* Detect location */ }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.purple)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Current Location").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                        Text("Detect automatically").font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding()
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Suggested Locations
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("location_suggested_title", comment: ""))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(["Istanbul", "London", "New York", "Dubai", "Berlin", "Singapore"], id: \.self) { city in
                                    CityCard(city: city, isSelected: selectedLocation == city) {
                                        selectedLocation = city
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                // Footer
                VStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text(NSLocalizedString("button_save_continue", comment: ""))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedLocation != nil ? Color(hex: "6C38FF") : Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .disabled(selectedLocation == nil)
                    .padding(24)
                }
                .background(AppColors.background)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
            Spacer()
            Image("ceopulse_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

struct LocationRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.system(size: 20))
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.purple : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct CityCard: View {
    let city: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .purple : AppColors.textSecondary)
                
                Text(city)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.purple.opacity(0.1) : Color.white.opacity(0.03))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}
