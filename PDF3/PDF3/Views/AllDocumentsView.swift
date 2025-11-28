import SwiftUI

struct AllDocumentsView: View {
    @ObservedObject var appState: AppState
    let onDocumentSelected: (PDFDocument) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedFilter = DocumentFilter.all
    @State private var showingDeleteAlert = false
    @State private var documentToDelete: PDFDocument?
    
    var filteredDocuments: [PDFDocument] {
        var documents = appState.documents
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .scanned:
            documents = documents.filter { $0.type == .scanned }
        case .converted:
            documents = documents.filter { $0.type == .converted }
        case .edited:
            documents = documents.filter { $0.type == .edited }
        case .signed:
            documents = documents.filter { $0.type == .signed }
        }
        
        // Apply search
        if !searchText.isEmpty {
            documents = documents.filter { document in
                document.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return documents.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search and Filter
                    searchAndFilterView
                    
                    // Documents List
                    documentsListView
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("All Documents")
                    .font(AppFonts.largeTitle)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(filteredDocuments.count) documents")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var searchAndFilterView: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("Search documents...", text: $searchText)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallCornerRadius))
            
            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DocumentFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.title,
                            isSelected: selectedFilter == filter,
                            count: getFilterCount(filter)
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
    
    private var documentsListView: some View {
        ScrollView {
            if filteredDocuments.isEmpty {
                EmptySearchView(searchText: searchText, filter: selectedFilter)
                    .padding(.top, 50)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredDocuments, id: \.id) { document in
                        DocumentCard(document: document) {
                            onDocumentSelected(document)
                            presentationMode.wrappedValue.dismiss()
                        }
                        .contextMenu {
                            Button(action: {
                                onDocumentSelected(document)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Label("View Document", systemImage: "eye")
                            }
                            
                            Button(action: {
                                // Navigate to PDF Editor with signature mode
                                onDocumentSelected(document)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Label("Add Signature", systemImage: "signature")
                            }
                            
                            Button(action: {
                                shareDocument(document)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(role: .destructive, action: {
                                documentToDelete = document
                                showingDeleteAlert = true
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .alert("Delete Document", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let document = documentToDelete {
                    appState.deleteDocument(document)
                    documentToDelete = nil
                }
            }
        } message: {
            if let document = documentToDelete {
                Text("Are you sure you want to delete '\(document.name)'? This action cannot be undone.")
            }
        }
    }
    
    private func getFilterCount(_ filter: DocumentFilter) -> Int {
        switch filter {
        case .all:
            return appState.documents.count
        case .scanned:
            return appState.documents.filter { $0.type == .scanned }.count
        case .converted:
            return appState.documents.filter { $0.type == .converted }.count
        case .edited:
            return appState.documents.filter { $0.type == .edited }.count
        case .signed:
            return appState.documents.filter { $0.type == .signed }.count
        }
    }
    
    private func shareDocument(_ document: PDFDocument) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        let sourceURL = pdfFolder.appendingPathComponent(document.name)
        
        var activityItems: [Any] = []
        
        if FileManager.default.fileExists(atPath: sourceURL.path) {
            activityItems.append(sourceURL)
        } else {
            activityItems.append("Check out this document: \(document.name)")
        }
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            activityVC.popoverPresentationController?.sourceView = window
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

enum DocumentFilter: CaseIterable {
    case all, scanned, converted, edited, signed
    
    var title: String {
        switch self {
        case .all: return "All"
        case .scanned: return "Scanned"
        case .converted: return "Converted"
        case .edited: return "Edited"
        case .signed: return "Signed"
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(isSelected ? .white.opacity(0.25) : AppColors.textSecondary.opacity(0.1))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.6))
            )
            .background(
                Capsule()
                    .fill(AppColors.primaryGradient)
                    .opacity(isSelected ? 1 : 0)
            )
            .shadow(color: isSelected ? AppColors.primaryBlue.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.3) : AppColors.textSecondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DocumentCard: View {
    let document: PDFDocument
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Document preview with gradient
                ZStack {
                    RoundedRectangle(cornerRadius: AppConstants.smallCornerRadius)
                        .fill(document.type.gradient)
                        .frame(width: 70, height: 85)
                        .shadow(color: document.type.color.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 6) {
                        Image(systemName: document.type.icon)
                            .font(.title)
                            .foregroundColor(.white)
                            .bold()
                        
                        Text("PDF")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("\(document.pages)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    // Shine effect
                    RoundedRectangle(cornerRadius: AppConstants.smallCornerRadius)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 70, height: 85)
                }
                
                // Document info
                VStack(alignment: .leading, spacing: 8) {
                    Text(document.name)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .bold()
                    
                    HStack(spacing: 16) {
                        Label("\(document.pages) pages", systemImage: "doc.text.fill")
                            .font(AppFonts.small)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Label(document.size, systemImage: "internaldrive.fill")
                            .font(AppFonts.small)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text(formatDate(document.dateCreated))
                        .font(AppFonts.small)
                        .foregroundColor(AppColors.textSecondary)
                    
                    // Type badge with gradient
                    HStack {
                        Text(document.type.activityTitle)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(document.type.gradient)
                            .clipShape(Capsule())
                            .shadow(color: document.type.color.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Arrow button
                ZStack {
                    Circle()
                        .fill(document.type.gradient.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(document.type.color)
                }
            }
            .padding(20)
            .modernCardStyle()
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(document.type.gradient.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptySearchView: View {
    let searchText: String
    let filter: DocumentFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔍")
                .font(.system(size: 64))
            
            VStack(spacing: 8) {
                Text("No documents found")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                if !searchText.isEmpty {
                    Text("No results for '\(searchText)'")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No \(filter.title.lowercased()) documents yet")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
    }
}