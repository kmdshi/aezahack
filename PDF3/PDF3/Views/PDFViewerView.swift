import SwiftUI
import PDFKit

struct PDFViewerView: View {
    let document: PDFDocument
    @ObservedObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var showingPDFEditor = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // PDF Viewer
                    PDFKitView(document: document, appState: appState)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                        .padding()
                    
                    // Action Buttons
                    actionButtonsView
                        .padding()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: createShareItems())
            }
            .sheet(isPresented: $showingPDFEditor) {
                PDFEditorView(document: document, appState: appState)
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
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(nil)
                
                Text("\(document.pages) pages • \(document.size)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Button(action: {
                showingShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryBlue)
            }
        }
        .padding()
        .background(Color.clear)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Primary actions row
            HStack(spacing: 16) {
                ActionButton(
                    title: "Add Signature",
                    icon: "signature",
                    color: AppColors.signColor
                ) {
                    showingPDFEditor = true
                }
                

            }
            
            // Secondary actions row
            HStack(spacing: 16) {
                ActionButton(
                    title: "Share",
                    icon: "square.and.arrow.up",
                    color: AppColors.convertColor
                ) {
                    showingShareSheet = true
                }
                
                ActionButton(
                    title: "Print",
                    icon: "printer.fill",
                    color: AppColors.scanColor
                ) {
                    printDocument()
                }
            }
        }
    }
    

    
    private func printDocument() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        let sourceURL = pdfFolder.appendingPathComponent(document.name)
        
        if FileManager.default.fileExists(atPath: sourceURL.path),
           let pdfDocument = PDFKit.PDFDocument(url: sourceURL) {
            
            let printController = UIPrintInteractionController.shared
            printController.printingItem = pdfDocument.dataRepresentation()
            
            printController.present(animated: true) { _, completed, error in
                if completed {
                    self.showToast("Print job sent successfully!")
                } else if let error = error {
                    self.showToast("Print failed: \(error.localizedDescription)")
                }
            }
        } else {
            showToast("PDF file not found for printing.")
        }
    }
    
    private func createShareItems() -> [Any] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        let sourceURL = pdfFolder.appendingPathComponent(document.name)
        
        if FileManager.default.fileExists(atPath: sourceURL.path) {
            return [sourceURL]
        } else {
            return ["Check out this PDF document: \(document.name)"]
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        showingToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingToast = false
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    let appState: AppState
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemGray6
        
        print("PDFKitView: Initializing PDF view for document: \(document.name)")
        
        // Try to load actual PDF file first, fallback to mock if not found
        if let actualPDF = loadActualPDFDocument() {
            print("PDFKitView: Loading actual PDF document")
            pdfView.document = actualPDF
        } else {
            print("PDFKitView: Actual PDF not available, creating mock document")
            if let mockPDF = createMockPDFDocument() {
                print("PDFKitView: Mock PDF created successfully")
                pdfView.document = mockPDF
            } else {
                print("PDFKitView: Failed to create mock PDF, creating emergency fallback")
                // Create a simple emergency fallback if even mock creation fails
                pdfView.document = createEmergencyPDFDocument()
            }
        }
        
        // Ensure the PDF view is properly configured
        DispatchQueue.main.async {
            if let document = pdfView.document, document.pageCount > 0 {
                print("PDFKitView: Successfully loaded document with \(document.pageCount) pages")
            } else {
                print("PDFKitView: Warning - No document loaded or document has no pages")
            }
        }
        
        return pdfView
    }
    
    private func createEmergencyPDFDocument() -> PDFKit.PDFDocument? {
        print("Creating emergency fallback PDF document")
        
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        
        // Fill with white background
        UIColor.white.setFill()
        UIRectFill(pageRect)
        
        // Add emergency content
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor.black
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.darkGray
        ]
        
        let title = document.name.replacingOccurrences(of: ".pdf", with: "")
        title.draw(in: CGRect(x: 50, y: 100, width: pageRect.width - 100, height: 50), withAttributes: titleAttributes)
        
        let content = """
        📄 PDF Document
        
        This document is ready to view.
        
        Type: \(document.type.activityTitle)
        Pages: \(document.pages)
        Size: \(document.size)
        
        Created with PDF Converter Pro
        """
        
        content.draw(in: CGRect(x: 50, y: 200, width: pageRect.width - 100, height: 400), withAttributes: bodyAttributes)
        
        UIGraphicsEndPDFContext()
        
        return PDFKit.PDFDocument(data: pdfData as Data)
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update if needed
    }
    
    private func loadActualPDFDocument() -> PDFKit.PDFDocument? {
        let pdfURL = appState.getPDFPath(for: document)
        
        print("Trying to load PDF from: \(pdfURL.path)")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: pdfURL.path) else {
            print("PDF file does not exist at path: \(pdfURL.path)")
            return nil
        }
        
        // Check file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: pdfURL.path)
            if let fileSize = attributes[FileAttributeKey.size] as? Int64 {
                print("PDF file size: \(fileSize) bytes")
                
                if fileSize == 0 {
                    print("PDF file is empty (0 bytes)")
                    return nil
                }
            }
        } catch {
            print("Failed to get PDF file attributes: \(error)")
        }
        
        // Attempt to create PDF document
        guard let pdfDocument = PDFKit.PDFDocument(url: pdfURL) else {
            print("Failed to create PDFDocument from file at \(pdfURL.path)")
            return nil
        }
        
        // Verify the document has content
        guard pdfDocument.pageCount > 0 else {
            print("PDF document has no pages")
            return nil
        }
        
        print("Successfully loaded PDF document with \(pdfDocument.pageCount) pages")
        return pdfDocument
    }
    
    private func createMockPDFDocument() -> PDFKit.PDFDocument? {
        print("Creating mock PDF document with \(document.pages) pages")
        
        // Create a simple PDF document for preview
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard letter size
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        for i in 1...max(1, document.pages) {  // Ensure at least 1 page
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            
            guard let context = UIGraphicsGetCurrentContext() else {
                print("Failed to get graphics context for page \(i)")
                continue
            }
            
            // Fill with white background
            context.setFillColor(UIColor.white.cgColor)
            context.fill(pageRect)
            
            // Add content to the page
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.darkGray
            ]
            
            let subheadingAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.darkGray
            ]
            
            // Title
            let title = "\(document.name.replacingOccurrences(of: ".pdf", with: ""))"
            let titleRect = CGRect(x: 50, y: 50, width: pageRect.width - 100, height: 40)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Page number
            let pageInfo = "Page \(i) of \(document.pages)"
            let pageInfoRect = CGRect(x: 50, y: 100, width: pageRect.width - 100, height: 25)
            pageInfo.draw(in: pageInfoRect, withAttributes: subheadingAttributes)
            
            // Document info
            let documentInfo = """
            Document Type: \(document.type.activityTitle)
            Created: \(DateFormatter.shortDate.string(from: document.dateCreated))
            File Size: \(document.size)
            Total Pages: \(document.pages)
            """
            
            let docInfoRect = CGRect(x: 50, y: 140, width: pageRect.width - 100, height: 80)
            documentInfo.draw(in: docInfoRect, withAttributes: bodyAttributes)
            
            // Main content
            let content = """
            This is a preview of your PDF document. The document was successfully \(document.type.activityDescription).
            
            PDF Converter Pro Features:
            
            • High-quality document scanning
            • File format conversion (Word, Images, etc.)
            • Digital signature support
            • Page editing and annotation
            • Secure document management
            • Easy sharing and export options
            
            To see the actual document content, ensure the original file is available in your device's storage. This preview is generated when the original document file cannot be loaded.
            
            Document ID: \(document.id.uuidString.prefix(8))
            Created with PDF Converter Pro
            """
            
            let contentRect = CGRect(x: 50, y: 240, width: pageRect.width - 100, height: pageRect.height - 300)
            content.draw(in: contentRect, withAttributes: bodyAttributes)
            
            // Footer
            let footer = "PDF Converter Pro - Document Viewer"
            let footerRect = CGRect(x: 50, y: pageRect.height - 80, width: pageRect.width - 100, height: 20)
            footer.draw(in: footerRect, withAttributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.lightGray
            ])
            
            print("Successfully created mock page \(i)")
        }
        
        UIGraphicsEndPDFContext()
        
        guard pdfData.length > 0 else {
            print("Mock PDF data is empty")
            return nil
        }
        
        let pdfDocument = PDFKit.PDFDocument(data: pdfData as Data)
        print("Mock PDF document created successfully with \(pdfDocument?.pageCount ?? 0) pages")
        return pdfDocument
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}