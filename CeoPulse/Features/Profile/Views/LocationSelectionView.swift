import SwiftUI

struct LocationSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedLocation = "İstanbul, Türkiye"
    
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
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Section
                        VStack(spacing: 8) {
                            Text("Lokasyonunuzu Ekleyin")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("Bulunduğunuz konum, size en uygun fırsatları görmenize yardımcı olur.")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.purple)
                            Text("Konum bilgileriniz yalnızca size özel fırsatları göstermek için kullanılır ve gizli tutulur.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary)
                            
                            TextField("", text: $searchText, prompt: Text("Şehir, ülke veya bölge ara").foregroundColor(AppColors.textSecondary))
                                .foregroundColor(.white)
                            
                            Button(action: {}) {
                                Image(systemName: "location.north.circle")
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        
                        // Current Location
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Mevcut Konumunuz")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            LocationRow(title: "İstanbul, Türkiye", isSelected: selectedLocation == "İstanbul, Türkiye") {
                                selectedLocation = "İstanbul, Türkiye"
                            }
                        }
                        
                        // Suggested Locations
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Önerilen Konumlar")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ForEach(suggestedLocations, id: \.self) { location in
                                    LocationRow(title: location, isSelected: selectedLocation == location) {
                                        selectedLocation = location
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
                        HStack {
                            Text("Devam Et")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "6C38FF"))
                        .cornerRadius(12)
                    }
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
