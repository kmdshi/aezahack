import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import VisionKit

struct MainView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        HomeView(appState: appState)
    }
}

// MARK: - Home View (Main Dashboard)
struct HomeView: View {
    @ObservedObject var appState: AppState
    @State private var showingSettings = false
    @State private var showingScanner = false
    @State private var showingFilePicker = false
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var showingAllDocuments = false
    @State private var selectedDocument: PDFDocument?
    @State private var showingPDFViewer = false
    @State private var showingPaywall = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingPhotoPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with Settings
                        headerView
                        
                        // Main Actions
                        mainActionsView
                        
                        // Quick Stats
                        quickStatsView
                        
                        // Recent Documents
                        recentDocumentsView
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView { result in
                    handleScanResult(result)
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPickerView { url in
                    convertFileToPDF(url)
                }
            }
            .sheet(isPresented: $showingAllDocuments) {
                AllDocumentsView(appState: appState) { document in
                    selectedDocument = document
                    showingPDFViewer = true
                }
            }
            .sheet(isPresented: $showingPDFViewer) {
                if let document = selectedDocument {
                    PDFViewerView(document: document, appState: appState)
                }
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView(appState: appState)
            }
            .photosPicker(isPresented: $showingPhotoPicker,
                         selection: $selectedPhotos,
                         maxSelectionCount: 10,
                         matching: .images)
            .onChange(of: selectedPhotos) { photos in
                handlePhotoSelection(photos)
            }
            .overlay(
                ToastView(message: toastMessage, isShowing: $showingToast)
                    .animation(.easeInOut, value: showingToast),
                alignment: .top
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning!")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                
                Text("PDF Converter Pro")
                    .font(AppFonts.largeTitle)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            Button(action: {
                showingSettings = true
            }) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryBlue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
        }
    }
    
    private var mainActionsView: some View {
        VStack(spacing: 16) {
            Text("What would you like to do?")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Conversion limit indicator
            if !appState.isPremium {
                conversionLimitCard
            }
            
            VStack(spacing: 16) {
                // Scan Documents
                MainActionCard(
                    title: "Scan Document",
                    subtitle: "Use camera to scan papers into PDF",
                    icon: "camera.fill",
                    emoji: "📷",
                    color: AppColors.scanColor,
                    gradient: AppColors.scanGradient
                ) {
                    if appState.canPerformConversion() {
                        showingScanner = true
                    } else {
                        showingPaywall = true
                    }
                }
                
                // Import & Convert Files
                MainActionCard(
                    title: "Import & Convert",
                    subtitle: "Choose files from device and convert to PDF",
                    icon: "square.and.arrow.down",
                    emoji: "📁",
                    color: AppColors.convertColor,
                    gradient: AppColors.convertGradient
                ) {
                    if appState.canPerformConversion() {
                        showingFilePicker = true
                    } else {
                        showingPaywall = true
                    }
                }
                
                // Import from Photo Gallery
                MainActionCard(
                    title: "Import Photos",
                    subtitle: "Select photos from gallery and convert to PDF",
                    icon: "photo.on.rectangle",
                    emoji: "🖼️",
                    color: AppColors.primaryBlue,
                    gradient: AppColors.lightGradient
                ) {
                    if appState.canPerformConversion() {
                        showingPhotoPicker = true
                    } else {
                        showingPaywall = true
                    }
                }
            }
        }
    }
    
    private var quickStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Documents",
                    value: "\(cumulativeStats.totalDocuments)",
                    icon: "doc.text.fill",
                    color: AppColors.primaryBlue,
                    gradient: AppColors.primaryGradient
                )
                
                StatCard(
                    title: "Scanned Today",
                    value: "\(cumulativeStats.todayDocuments)",
                    icon: "camera.fill",
                    color: AppColors.scanColor,
                    gradient: AppColors.scanGradient
                )
            }
        }
    }
    
    private var recentDocumentsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if !appState.documents.isEmpty {
                    Button("View All") {
                        showingAllDocuments = true
                    }
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            
            if appState.documents.isEmpty {
                EmptyDocumentsView()
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(appState.documents.prefix(3)), id: \.id) { document in
                        DocumentRowView(
                            document: document,
                            onTap: {
                                selectedDocument = document
                                showingPDFViewer = true
                            },
                            onDelete: {
                                appState.deleteDocument(document)
                                showToast("Document deleted successfully")
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var documentsToday: Int {

        let today = Calendar.current.startOfDay(for: Date())
        return appState.documents.filter {
            Calendar.current.isDate($0.dateCreated, inSameDayAs: today)
        }.count
    }

    // Накопительная статистика для Quick Stats
    private var cumulativeStats: (totalDocuments: Int, todayDocuments: Int) {
        return appState.getCumulativeStatistics()
    }
    
    private func handleScanResult(_ result: DocumentScannerResult) {
        print("📷 Handling scan result with \(result.images.count) images and \(result.pageCount) pages")
        
        // Check if we got valid images
        guard !result.images.isEmpty else {
            print("⚠️ No images received from scanner")
            return
        }
        
        // Create PDF file name with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "Scanned_\(timestamp).pdf"
        
        print("📄 Generated filename: \(fileName)")
        
        // Save scanned images as PDF
        if saveToPDF(images: result.images, fileName: fileName) {
            print("✅ PDF saved successfully, creating document record")
            
            let newDocument = PDFDocument(
                id: UUID(),
                name: fileName,
                type: .scanned,
                size: calculateFileSize(pageCount: result.pageCount),
                pages: result.pageCount,
                dateCreated: Date(),
                thumbnailImage: nil
            )
            
            print("📋 Creating document: \(newDocument)")
            appState.addDocument(newDocument)
            
            // Increment conversion count
            appState.incrementConversionCount()
            
            // Verify the file exists after adding document
            let pdfPath = appState.getPDFPath(for: newDocument)
            let fileExists = FileManager.default.fileExists(atPath: pdfPath.path)
            print("File verification after adding document - exists: \(fileExists) at path: \(pdfPath.path)")
            
            showToast("📄 Document scanned and saved as PDF!")
            
            // Check if should show paywall after successful scan
            if appState.shouldShowPaywall() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingPaywall = true
                }
            }
        } else {
            print("❌ Failed to save PDF file")
            showToast("❌ Failed to save document. Please try again.")
        }
    }
    
    private func convertFileToPDF(_ url: URL) {
        let fileName = "\(url.deletingPathExtension().lastPathComponent).pdf"
        
        // Convert file to PDF based on type
        if convertFileToPDFFormat(sourceURL: url, outputFileName: fileName) {
            let newDocument = PDFDocument(
                id: UUID(),
                name: fileName,
                type: .converted,
                size: estimateFileSize(from: url),
                pages: estimatePageCount(from: url),
                dateCreated: Date(),
                thumbnailImage: nil
            )
            
            appState.addDocument(newDocument)
            
            // Increment conversion count
            appState.incrementConversionCount()
            
            showToast("File converted to PDF and saved!")
            
            // Check if should show paywall after successful conversion
            if appState.shouldShowPaywall() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingPaywall = true
                }
            }
        } else {
            showToast("Failed to convert file. Please try again.")
        }
    }
    
    private func saveToPDF(images: [UIImage], fileName: String) -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        let pdfURL = pdfFolder.appendingPathComponent(fileName)
        
        print("Attempting to save PDF to: \(pdfURL.path)")
        
        // Ensure PDFs directory exists
        do {
            try FileManager.default.createDirectory(at: pdfFolder, withIntermediateDirectories: true)
            print("PDFs directory created/exists at: \(pdfFolder.path)")
        } catch {
            print("Failed to create PDFs directory: \(error)")
            return false
        }
        
        guard let pdfData = createPDFFromImages(images) else {
            print("Failed to create PDF data from images")
            return false
        }
        
        print("Created PDF data with size: \(pdfData.count) bytes")
        
        do {
            try pdfData.write(to: pdfURL)
            print("Successfully saved PDF to: \(pdfURL.path)")
            
            // Verify file was actually created
            if FileManager.default.fileExists(atPath: pdfURL.path) {
                let fileSize = try? FileManager.default.attributesOfItem(atPath: pdfURL.path)[.size] as? Int ?? 0
                print("File verified exists with size: \(fileSize ?? 0) bytes")
                return true
            } else {
                print("File was not created despite no write error")
                return false
            }
        } catch {
            print("Error saving PDF: \(error)")
            return false
        }
    }
    
    private func convertFileToPDFFormat(sourceURL: URL, outputFileName: String) -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        let pdfURL = pdfFolder.appendingPathComponent(outputFileName)
        
        // Ensure PDFs directory exists
        try? FileManager.default.createDirectory(at: pdfFolder, withIntermediateDirectories: true)
        
        // Simulate conversion based on file type
        if let pdfData = createPDFFromFile(sourceURL: sourceURL) {
            do {
                try pdfData.write(to: pdfURL)
                return true
            } catch {
                print("Error saving converted PDF: \(error)")
                return false
            }
        }
        
        return false
    }
    
    private func handlePhotoSelection(_ photos: [PhotosPickerItem]) {
        guard !photos.isEmpty else { return }
        
        Task {
            var images: [UIImage] = []
            
            for photo in photos {
                if let data = try? await photo.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            
            guard !images.isEmpty else {
                await MainActor.run {
                    showToast("Failed to load selected photos")
                }
                return
            }
            
            await MainActor.run {
                convertPhotosToPDF(images: images)
                selectedPhotos.removeAll() // Clear selection
            }
        }
    }
    
    private func convertPhotosToPDF(images: [UIImage]) {
        // Create PDF file name with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "Photos_\(timestamp).pdf"
        
        print("Converting \(images.count) photos to PDF: \(fileName)")
        
        // Save photos as PDF
        if saveToPDF(images: images, fileName: fileName) {
            print("PDF saved successfully from photos, creating document record")
            
            let newDocument = PDFDocument(
                id: UUID(),
                name: fileName,
                type: .converted,
                size: calculateFileSize(pageCount: images.count),
                pages: images.count,
                dateCreated: Date(),
                thumbnailImage: nil
            )
            
            print("Creating document from photos: \(newDocument)")
            appState.addDocument(newDocument)
            
            // Increment conversion count
            appState.incrementConversionCount()
            
            showToast("Photos converted to PDF successfully!")
            
            // Check if should show paywall after successful conversion
            if appState.shouldShowPaywall() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingPaywall = true
                }
            }
        } else {
            print("Failed to save PDF from photos")
            showToast("Failed to convert photos. Please try again.")
        }
    }
    
    private func createPDFFromImages(_ images: [UIImage]) -> Data? {
        guard !images.isEmpty else {
            print("No images provided to create PDF")
            return nil
        }
        
        print("Creating PDF from \(images.count) images")
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        
        for (index, image) in images.enumerated() {
            print("Processing image \(index + 1) of \(images.count) with size: \(image.size)")
            
            let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard letter size
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            
            // Calculate image size to fit page while maintaining aspect ratio
            let imageSize = image.size
            let aspectRatio = imageSize.width / imageSize.height
            let pageAspectRatio = pageRect.width / pageRect.height
            
            var drawRect: CGRect
            if aspectRatio > pageAspectRatio {
                // Image is wider
                let newHeight = pageRect.width / aspectRatio
                drawRect = CGRect(x: 0, y: (pageRect.height - newHeight) / 2, width: pageRect.width, height: newHeight)
            } else {
                // Image is taller
                let newWidth = pageRect.height * aspectRatio
                drawRect = CGRect(x: (pageRect.width - newWidth) / 2, y: 0, width: newWidth, height: pageRect.height)
            }
            
            print("Drawing image in rect: \(drawRect)")
            image.draw(in: drawRect)
        }
        
        UIGraphicsEndPDFContext()
        
        print("PDF creation completed, data size: \(pdfData.length) bytes")
        
        return pdfData as Data
    }
    
    private func createPDFFromFile(sourceURL: URL) -> Data? {
        let pdfData = NSMutableData()
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        
        // Add content based on file type
        let fileName = sourceURL.lastPathComponent
        let fileExtension = sourceURL.pathExtension.lowercased()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        
        let title = "Converted Document"
        let content = """
        Original File: \(fileName)
        File Type: \(fileExtension.uppercased())
        Converted: \(Date().formatted())
        
        This document was converted to PDF using PDF Converter Pro.
        """
        
        title.draw(in: CGRect(x: 50, y: 50, width: pageRect.width - 100, height: 30), withAttributes: titleAttributes)
        content.draw(in: CGRect(x: 50, y: 100, width: pageRect.width - 100, height: pageRect.height - 150), withAttributes: bodyAttributes)
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
    private func calculateFileSize(pageCount: Int) -> String {
        let baseSizePerPage = 150.0 // KB
        let totalSize = Double(pageCount) * baseSizePerPage
        
        if totalSize < 1024 {
            return String(format: "%.0f KB", totalSize)
        } else {
            return String(format: "%.1f MB", totalSize / 1024)
        }
    }
    
    private func estimateFileSize(from url: URL) -> String {
        do {
            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? 0
            let sizeInKB = Double(fileSize) / 1024
            
            if sizeInKB < 1024 {
                return String(format: "%.0f KB", sizeInKB)
            } else {
                return String(format: "%.1f MB", sizeInKB / 1024)
            }
        } catch {
            return "Unknown"
        }
    }
    
    private func estimatePageCount(from url: URL) -> Int {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return 1 // Will be calculated properly in real implementation
        case "doc", "docx", "txt":
            return 1 // Estimate based on file size
        case "jpg", "jpeg", "png", "heic":
            return 1
        default:
            return 1
        }
    }
    
    private var conversionLimitCard: some View {
        let remainingConversions = max(0, 5 - appState.conversionCount)
        
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                if remainingConversions > 0 {
                    Text("Free conversions remaining")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(remainingConversions) of 5")
                        .font(AppFonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryBlue)
                } else {
                    Text("Free limit reached")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Upgrade to continue")
                        .font(AppFonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            
            Spacer()
            
            if remainingConversions <= 0 {
                Button("Upgrade") {
                    showingPaywall = true
                }
                .font(AppFonts.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.primaryGradient)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primaryBlue.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: AppColors.shadowColor.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        showingToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingToast = false
        }
    }
}

// MARK: - Supporting Views
struct MainActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let emoji: String
    let color: Color
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Gradient icon background
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 70, height: 70)
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 2) {
                        Text(emoji)
                            .font(.system(size: 28))
                        
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Glow effect overlay
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 70, height: 70)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .bold()
                    
                    Text(subtitle)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow with gradient background
                ZStack {
                    Circle()
                        .fill(gradient.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                }
            }
            .padding(24)
            .modernCardStyle()
            .overlay(
                // Shimmer effect border
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(gradient.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 45, height: 45)
                        .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                        .bold()
                }
                
                Spacer()
                
                // Decorative element
                Circle()
                    .fill(gradient.opacity(0.1))
                    .frame(width: 20, height: 20)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .modernCardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .stroke(gradient.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DocumentRowView: View {
    let document: PDFDocument
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Document icon with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: AppConstants.smallCornerRadius)
                        .fill(document.type.gradient.opacity(0.8))
                        .frame(width: 50, height: 60)
                        .shadow(color: document.type.color.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    VStack(spacing: 4) {
                        Image(systemName: document.type.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .bold()
                        
                        Text("PDF")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                // Document info
                VStack(alignment: .leading, spacing: 6) {
                    Text(document.name)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(nil)
                    
                    HStack(spacing: 12) {
                        Label("\(document.pages)", systemImage: "doc.text")
                            .font(AppFonts.small)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Label(document.size, systemImage: "internaldrive")
                            .font(AppFonts.small)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text(formatRelativeTime(document.dateCreated))
                        .font(AppFonts.tiny)
                        .foregroundColor(AppColors.textSecondary)
                    
                    // Type badge
                    Text(document.type.activityTitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(document.type.color)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 8) {
                    if let onDelete = onDelete {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(AppColors.deleteGradient)
                                .clipShape(Circle())
                                .shadow(color: Color.red.opacity(0.3), radius: 3, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(20)
            .modernCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Delete Document", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete '\(document.name)'? This action cannot be undone.")
        }
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EmptyDocumentsView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(AppColors.lightGradient.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 20, x: 0, y: 10)
                
                Circle()
                    .fill(AppColors.primaryGradient.opacity(0.5))
                    .frame(width: 90, height: 90)
                
                Text("📄")
                    .font(.system(size: 48))
            }
            
            VStack(spacing: 12) {
                Text("No documents yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Start by scanning or importing your first document to get started with PDF management!")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Action buttons
            HStack(spacing: 16) {
               
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .modernCardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .stroke(AppColors.lightGradient.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Document Scanner
struct DocumentScannerView: UIViewControllerRepresentable {
    let completion: (DocumentScannerResult) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Check if VNDocumentCameraViewController is available (iOS 13+)
        guard VNDocumentCameraViewController.isSupported else {
            // Fallback for devices that don't support document scanning
            return createFallbackViewController()
        }
        
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    private func createFallbackViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = "📷"
        iconLabel.font = UIFont.systemFont(ofSize: 64)
        iconLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = "Сканирование недоступно"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        let messageLabel = UILabel()
        messageLabel.text = "Функция сканирования документов\nне поддерживается на этом устройстве"
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Закрыть", for: .normal)
        dismissButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        dismissButton.addAction(UIAction { _ in
            vc.dismiss(animated: true)
        }, for: .touchUpInside)
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(dismissButton)
        
        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: vc.view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -40)
        ])
        
        return vc
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let completion: (DocumentScannerResult) -> Void
        
        init(completion: @escaping (DocumentScannerResult) -> Void) {
            self.completion = completion
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            
            for pageIndex in 0..<scan.pageCount {
                let scannedImage = scan.imageOfPage(at: pageIndex)
                images.append(scannedImage)
            }
            
            let result = DocumentScannerResult(pageCount: scan.pageCount, images: images)
            completion(result)
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("❌ Document scanning failed with error: \(error.localizedDescription)")
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            print("📷 User cancelled document scanning")
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Document Picker
struct DocumentPickerView: UIViewControllerRepresentable {
    let completion: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .pdf, .image])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL) -> Void
        
        init(completion: @escaping (URL) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                completion(url)
            }
        }
    }
}

// MARK: - Models
struct DocumentScannerResult {
    let pageCount: Int
    let images: [UIImage]
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

// MARK: - Toast View
struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            if isShowing {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .background(AppColors.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallCornerRadius))
                .shadow(color: AppColors.shadowColor, radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            Spacer()
        }
    }
}
