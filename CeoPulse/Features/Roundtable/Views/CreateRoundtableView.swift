import SwiftUI

struct CreateRoundtableView: View {
    @StateObject private var viewModel = CreateRoundtableViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Step 1: Masa Bilgileri
                        StepSection(number: 1, title: "Masa Bilgileri") {
                            VStack(alignment: .leading, spacing: 16) {
                                FormField(label: "Masa Başlığı", count: "\(viewModel.title.count)/80") {
                                    TextField("Örneğin: 2026'da Yapay Zeka ve Liderlik", text: $viewModel.title)
                                        .limitCharacters($viewModel.title, limit: 80)
                                }
                                
                                FormField(label: "Masa Açıklaması", count: "\(viewModel.description.count)/500") {
                                    TextEditor(text: $viewModel.description)
                                        .frame(height: 100)
                                        .limitCharacters($viewModel.description, limit: 500)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.white.opacity(0.02))
                                }
                                
                                FormField(label: "Kategori") {
                                    CategoryPicker(selected: $viewModel.selectedCategory)
                                }
                            }
                        }
                        
                        // Step 2: Oturum Ayarları
                        StepSection(number: 2, title: "Oturum Ayarları") {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 16) {
                                    FormField(label: "Tarih") {
                                        DatePickerField(date: $viewModel.selectedDate, icon: "calendar")
                                    }
                                    FormField(label: "Başlangıç Saati") {
                                        DatePickerField(date: $viewModel.selectedTime, icon: "clock", mode: .hourAndMinute)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    FormField(label: "Tahmini Süre") {
                                        DropdownField(selection: $viewModel.estimatedDuration, icon: "clock")
                                    }
                                    FormField(label: "Katılımcı Sayısı") {
                                        DropdownField(selection: $viewModel.participantCount, icon: "person.2")
                                    }
                                }
                                
                                Text("Masa Türü")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack(spacing: 12) {
                                    TableTypeCard(
                                        title: "Açık Masa",
                                        subtitle: "Herkese açık, herkes katılabilir.",
                                        icon: "network",
                                        isSelected: viewModel.tableType == .open,
                                        action: { viewModel.tableType = .open }
                                    )
                                    
                                    TableTypeCard(
                                        title: "Davetli Masa",
                                        subtitle: "Sadece davet ettiğiniz kişiler katılabilir.",
                                        icon: "lock",
                                        isSelected: viewModel.tableType == .invited,
                                        action: { viewModel.tableType = .invited }
                                    )
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Kimler Katılabilir?")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    HStack(spacing: 20) {
                                        RadioButtonField(label: "Herkes (Açık)", isSelected: viewModel.whoCanJoin == .everyone, action: { viewModel.whoCanJoin = .everyone })
                                        RadioButtonField(label: "Premium Üyeler", isSelected: viewModel.whoCanJoin == .premium, action: { viewModel.whoCanJoin = .premium })
                                        RadioButtonField(label: "Davetliler", isSelected: viewModel.whoCanJoin == .invitedOnly, action: { viewModel.whoCanJoin = .invitedOnly })
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        // Step 3: Konuşma Çerçevesi
                        StepSection(number: 3, title: "Konuşma Çerçevesi") {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Tartışma Soruları (İsteğe bağlı)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                    Button(action: { /* Add question logic */ }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus")
                                            Text("Soru Ekle")
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.purple)
                                    }
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(viewModel.discussionQuestions.enumerated()), id: \.offset) { index, question in
                                        QuestionRow(number: index + 1, question: question) {
                                            viewModel.removeQuestion(at: index)
                                        }
                                    }
                                }
                                
                                Text("En az 1 soru eklemeniz tartışmayı daha verimli hale getirir.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        
                        // Create Button
                        Button(action: {
                            Task { await viewModel.createRoundtable() }
                        }) {
                            HStack(spacing: 8) {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Yuvarlak Masayı Oluştur")
                                }
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .cornerRadius(16)
                            .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                        Text("PREMIUM")
                            .font(.system(size: 10, weight: .black))
                    }
                    .foregroundColor(Color(hex: "FFB800"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "FFB800").opacity(0.1))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "FFB800").opacity(0.5), lineWidth: 1))
                }
                
                Text("Yuvarlak Masa Oluştur")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Fikirleri bir araya getir, değerli içgörüler kazan.")
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Supporting Views

struct StepSection<Content: View>: View {
    let number: Int
    let title: String
    let content: Content
    
    init(number: Int, title: String, @ViewBuilder content: () -> Content) {
        self.number = number
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 28, height: 28)
                    Text("\(number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            content
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct FormField<Content: View>: View {
    let label: String
    var count: String? = nil
    let content: Content
    
    init(label: String, count: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.count = count
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                if let count = count {
                    Text(count)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            content
                .padding(12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
}

struct CategoryPicker: View {
    @Binding var selected: String
    
    var body: some View {
        HStack {
            Image(systemName: "square.and.pencil")
                .foregroundColor(.white.opacity(0.4))
            Text(selected.isEmpty ? "Kategori seçin" : selected)
                .foregroundColor(selected.isEmpty ? .white.opacity(0.4) : .white)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.white.opacity(0.4))
        }
        .font(.system(size: 14))
    }
}

struct DatePickerField: View {
    @Binding var date: Date
    let icon: String
    var mode: DatePickerComponents = .date
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.4))
            Text(mode == .date ? date.formatted(date: .long, time: .omitted) : date.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
            if mode == .date {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.4))
            } else {
                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.4))
            }
        }
    }
}

struct DropdownField: View {
    @Binding var selection: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.4))
            Text(selection)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.white.opacity(0.4))
        }
    }
}

struct TableTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.purple.opacity(0.2) : Color.white.opacity(0.05))
                            .frame(width: 32, height: 32)
                        Image(systemName: icon)
                            .foregroundColor(isSelected ? .purple : .white.opacity(0.4))
                            .font(.system(size: 14))
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.purple)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.purple.opacity(0.05) : Color.white.opacity(0.02))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.purple : Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct RadioButtonField: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.purple : Color.white.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
        }
    }
}

struct QuestionRow: View {
    let number: Int
    let question: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.white.opacity(0.2))
            
            Text("\(number).")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
            
            Text(question)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.02))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

// MARK: - Character Limit Helper
extension View {
    func limitCharacters(_ binding: Binding<String>, limit: Int) -> some View {
        onChange(of: binding.wrappedValue) { newValue in
            if newValue.count > limit {
                binding.wrappedValue = String(newValue.prefix(limit))
            }
        }
    }
}
