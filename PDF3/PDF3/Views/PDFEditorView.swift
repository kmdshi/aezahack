import SwiftUI
import PDFKit
import PencilKit
import Foundation

struct PDFEditorView: View {
    let document: PDFDocument
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var pdfDocument: PDFKit.PDFDocument?
    @State private var currentPage: Int = 0
    @State private var isSaving = false
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""
    @State private var annotationMode: AnnotationMode = .none
    
    // Signature states
    @State private var showingSignaturePad = false
    @State private var signatureImage: UIImage?
    @State private var isSignaturePlaced = false
    @State private var signaturePosition = CGPoint.zero
    @State private var signatureSize = CGSize(width: 150, height: 75)
    @State private var signatureOffset = CGSize.zero
    @State private var originalSignatureSize = CGSize.zero  // Store original size for reset
    @State private var currentViewGeometry = CGSize.zero    // Store current view geometry for accurate coordinate conversion
    @State private var isDraggingSignature = false         // Track dragging state for smooth animations
    @State private var showSignaturePulse = false          // Show pulsing animation for new signature
    @State private var hasAppliedSignature = false
    
    enum AnnotationMode {
        case none, text, signature
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                toolbarView
                pdfContentView
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSignaturePad) {
            if #available(iOS 14.0, *) {
                SignaturePadView { signature in
                    handleSignatureCreated(signature)
                }
            } else {
                // Fallback for older iOS versions
                SimpleSignaturePadView { signature in
                    handleSignatureCreated(signature)
                }
            }
        }
        .overlay(signatureOverlay)
        .alert("Document Saved", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveMessage)
        }
        .onAppear {
            loadPDFDocument()
        }
    }
    
    private var toolbarView: some View {
        VStack(spacing: 8) {
            // Top toolbar row - navigation and save
            HStack {
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(AppColors.primaryBlue)
                .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                saveButton
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Bottom toolbar row - annotation tools (scrollable)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Main annotation tools
                    HStack(spacing: 10) {
                        ToolButton(
                            icon: "textformat",
                            isSelected: annotationMode == .text,
                            gradient: AppColors.editGradient,
                            action: {
                                annotationMode = annotationMode == .text ? .none : .text
                            }
                        )
                        
                        ToolButton(
                            icon: "signature",
                            isSelected: annotationMode == .signature,
                            gradient: AppColors.signGradient,
                            action: {
                                print("=== Signature button tapped! ===")
                                print("Current showingSignaturePad state: \(showingSignaturePad)")
                                print("Current annotationMode: \(annotationMode)")
                                
                                DispatchQueue.main.async {
                                    showingSignaturePad = true
                                    print("Updated showingSignaturePad to: \(showingSignaturePad)")
                                }
                            }
                        )
                    }
                    
                    // Signature size controls (compact version when signature is placed)
                    if isSignaturePlaced {
                        Divider()
                            .frame(height: 30)
                            .padding(.horizontal, 4)
                        
                        compactSignatureSizeControls
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
        }
        .background(
            Color.white
                .shadow(color: AppColors.shadowColor.opacity(0.2), radius: 2, x: 0, y: 1)
        )
    }
    
    private var saveButton: some View {
        Button(action: {
            print("=== Save button tapped! ===")
            print("Current PDF document: \(pdfDocument != nil ? "exists" : "nil")")
            print("Document name: \(document.name)")
            print("Current annotation mode: \(annotationMode)")
            print("Is signature placed: \(isSignaturePlaced)")
            print("Has applied signature: \(hasAppliedSignature)")
            print("Signature image exists: \(signatureImage != nil)")
            
            // Prevent multiple save attempts
            guard !isSaving else {
                print("⚠️ Save already in progress - ignoring")
                return
            }
            
            // Set saving state
            isSaving = true
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Execute save immediately
            saveEditedDocument()
        }) {
            HStack(spacing: 6) {
                if isSaving {
                    ProgressView()
                        .scaleEffect(0.7)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Saving...")
                        .font(.system(size: 14, weight: .medium))
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: isSaving ? 
                        [Color.gray.opacity(0.7), Color.gray.opacity(0.5)] :
                        [AppColors.primaryBlue, Color.blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .scaleEffect(isSaving ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isSaving)
        }
        .disabled(isSaving)
    }
    
    private var compactSignatureSizeControls: some View {
        HStack(spacing: 4) {
            // Small size
            AnimatedSizeControlButton(
                label: "S", 
                color: .blue.opacity(0.8),
                isSelected: abs(signatureSize.width - 120) < 5
            ) {
                let aspectRatio = signatureSize.width / signatureSize.height
                let newSize = CGSize(width: 120, height: 120 / aspectRatio)
                animateSignatureResize(to: newSize)
                hapticFeedback(.light)
            }
            
            // Medium size
            AnimatedSizeControlButton(
                label: "M", 
                color: .blue,
                isSelected: abs(signatureSize.width - 180) < 5
            ) {
                let aspectRatio = signatureSize.width / signatureSize.height
                let newSize = CGSize(width: 180, height: 180 / aspectRatio)
                animateSignatureResize(to: newSize)
                hapticFeedback(.light)
            }
            
            // Large size
            AnimatedSizeControlButton(
                label: "L", 
                color: .blue.opacity(1.0),
                isSelected: abs(signatureSize.width - 240) < 5
            ) {
                let aspectRatio = signatureSize.width / signatureSize.height
                let newSize = CGSize(width: 240, height: 240 / aspectRatio)
                animateSignatureResize(to: newSize)
                hapticFeedback(.light)
            }
            
            // Reset to original size
            AnimatedSizeControlButton(
                label: "⟲", 
                color: .orange.opacity(0.8),
                isSelected: signatureSize == originalSignatureSize
            ) {
                animateSignatureResize(to: originalSignatureSize)
                hapticFeedback(.medium)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .animation(.interpolatingSpring(stiffness: 200, damping: 35), value: signatureSize)
    }
    
    // Helper function for animated signature resize
    private func animateSignatureResize(to newSize: CGSize) {
        withAnimation(.interpolatingSpring(stiffness: 180, damping: 35)) {
            signatureSize = newSize
            // Re-constrain position after size change
            signaturePosition = constrainPositionToBounds(signaturePosition, in: UIScreen.main.bounds.size)
        }
    }
    
    // Helper function for haptic feedback
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.prepare() // Pre-prepare for smoother feedback
        impactFeedback.impactOccurred(intensity: style == .light ? 0.5 : 0.8)
    }
    
    private var pdfContentView: some View {
        Group {
            if let pdfDocument = pdfDocument {
                PDFEditorContentView(
                    pdfDocument: pdfDocument,
                    currentPage: $currentPage,
                    annotationMode: $annotationMode,
                    onTap: { location in
                        handlePDFTap(at: location)
                    }
                )
            } else {
                VStack {
                    ProgressView()
                    Text("Loading PDF...")
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var signatureOverlay: some View {
        GeometryReader { geometry in
            Group {
                if isSignaturePlaced, let signatureImage = signatureImage {
                    ResizableSignatureOverlayView(
                        image: signatureImage,
                        position: constrainPositionToBounds(signaturePosition, in: geometry.size),
                        size: signatureSize,
                        offset: signatureOffset,
                        screenSize: geometry.size,
                        onDragChanged: { value in
                            // Stop pulsing animation on first touch
                            if showSignaturePulse {
                                showSignaturePulse = false
                            }
                            
                            // Smooth drag with haptic feedback
                            withAnimation(.spring(response: 0.15, dampingFraction: 0.8, blendDuration: 0)) {
                                signatureOffset = value.translation
                                isDraggingSignature = true
                            }
                            
                            // Light haptic feedback every 15 pixels of movement
                            let movementDistance = sqrt(value.translation.width * value.translation.width + value.translation.height * value.translation.height)
                            if Int(movementDistance) % 15 == 0 {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred(intensity: 0.3)
                            }
                        },
                        onDragEnded: { value in
                            // Smooth transition to final position
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                                let newPosition = CGPoint(
                                    x: signaturePosition.x + value.translation.width,
                                    y: signaturePosition.y + value.translation.height
                                )
                                signaturePosition = constrainPositionToBounds(newPosition, in: geometry.size)
                                signatureOffset = .zero
                                isDraggingSignature = false
                            }
                            
                            // Enhanced haptic feedback on drop
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred(intensity: 0.7)
                        },
                        onSizeChanged: { newSize in
                            withAnimation(.interpolatingSpring(stiffness: 220, damping: 35)) {
                                signatureSize = newSize
                                // Re-constrain position after size change with smooth transition
                                signaturePosition = constrainPositionToBounds(signaturePosition, in: geometry.size)
                            }
                        }
                    )
                    .scaleEffect(showSignaturePulse && !isDraggingSignature ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showSignaturePulse)
                    .overlay(
                        // Enhanced preview indicator showing where signature will be saved in PDF
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                isDraggingSignature ? Color.green.opacity(0.9) : Color.green.opacity(0.6), 
                                lineWidth: isDraggingSignature ? 2 : 1
                            )
                            .background(
                                isDraggingSignature ? Color.green.opacity(0.15) : Color.green.opacity(0.1)
                            )
                            .frame(width: signatureSize.width + 4, height: signatureSize.height + 4)
                            .position(
                                x: constrainPositionToBounds(signaturePosition, in: geometry.size).x + signatureOffset.width + signatureSize.width / 2,
                                y: constrainPositionToBounds(signaturePosition, in: geometry.size).y + signatureOffset.height + signatureSize.height / 2
                            )
                            .opacity(isDraggingSignature ? 0.9 : 0.7)
                            .scaleEffect(isDraggingSignature ? 1.02 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: isDraggingSignature)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: signatureOffset)
                    )
                    .onAppear {
                        // Store the current geometry for accurate coordinate conversion during save
                        currentViewGeometry = geometry.size
                    }
                    .onChange(of: geometry.size) { newSize in
                        currentViewGeometry = newSize
                    }
                }
            }
        }
    }
    
    private func constrainPositionToBounds(_ position: CGPoint, in screenSize: CGSize) -> CGPoint {
        let margin: CGFloat = 40  // Отступ от краёв экрана
        let expandedPadding: CGFloat = 120  // Увеличенный padding для области нажатия
        let handleSize: CGFloat = expandedPadding  // Размер области нажатия
        let toolbarHeight: CGFloat = 120  // Высота toolbar сверху
        let bottomSafeArea: CGFloat = 80   // Безопасная зона снизу
        
        let minX = margin
        let maxX = max(minX, screenSize.width - signatureSize.width - margin - (handleSize / 2))
        let minY = toolbarHeight + margin 
        let maxY = max(minY, screenSize.height - signatureSize.height - bottomSafeArea - (handleSize / 2))
        
        let constrainedX = max(minX, min(position.x, maxX))
        let constrainedY = max(minY, min(position.y, maxY))
        
        print("🔒 Constraining position from \(position) to \(CGPoint(x: constrainedX, y: constrainedY))")
        print("📱 Screen size: \(screenSize), signature size: \(signatureSize)")
        
        return CGPoint(x: constrainedX, y: constrainedY)
    }
    
    private func loadPDFDocument() {
        let documentPath = appState.getPDFPath(for: document)
        
        if FileManager.default.fileExists(atPath: documentPath.path) {
            if let loadedDocument = PDFKit.PDFDocument(url: documentPath) {
                self.pdfDocument = loadedDocument
                print("Successfully loaded PDF document with \(loadedDocument.pageCount) pages")
            } else {
                print("Failed to load PDF document, creating mock document")
                self.pdfDocument = createMockPDFDocument()
            }
        } else {
            print("PDF file does not exist at path: \(documentPath.path), creating mock document")
            self.pdfDocument = createMockPDFDocument()
        }
    }
    
    private func createMockPDFDocument() -> PDFKit.PDFDocument? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        
        // Create PDF data
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        // Create a page
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        
        // Draw some content
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            print("Failed to get graphics context in createMockPDFDocument")
            return nil
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(pageRect)
        
        // Add some text
        let text = "Sample PDF Document\n\nThis is a mock PDF document for testing the PDF editor functionality."
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        text.draw(in: CGRect(x: 50, y: 50, width: 512, height: 692), withAttributes: attributes)
        
        UIGraphicsEndPDFContext()
        
        return PDFKit.PDFDocument(data: pdfData as Data)
    }
    
    private func saveEditedDocument() {
        print("=== STARTING DOCUMENT SAVE PROCESS ===")
        print("📊 Current state check:")
        print("  - PDF Document: \(pdfDocument != nil ? "✅ Available" : "❌ Missing")")
        print("  - Signature placed: \(isSignaturePlaced)")
        print("  - Signature applied: \(hasAppliedSignature)")
        print("  - Signature image: \(signatureImage != nil ? "✅ Available" : "❌ Missing")")
        
        guard let pdfDocument = pdfDocument else {
            print("❌ ERROR: No PDF document to save")
            DispatchQueue.main.async {
                self.isSaving = false
                self.saveMessage = "❌ No document to save. Please try again."
                self.showingSaveAlert = true
            }
            return
        }
        
        print("✅ PDF document available with \(pdfDocument.pageCount) pages")
        print("📋 Document info: type=\(document.type), name=\(document.name)")
        
        // Check if we have a signature to embed
        if isSignaturePlaced && !hasAppliedSignature, let signature = signatureImage {
            print("📝 Signature found - embedding before saving...")
            
            // Calculate final position including any current offset
            let finalPosition = CGPoint(
                x: signaturePosition.x + signatureOffset.width,
                y: signaturePosition.y + signatureOffset.height
            )
            
            print("📍 Final signature position: \(finalPosition) (base: \(signaturePosition), offset: \(signatureOffset))")
            print("📏 Final signature size: \(signatureSize)")
            print("📱 Current view geometry for conversion: \(currentViewGeometry)")
            
            // Apply signature synchronously to ensure it's embedded before saving
            applySignatureToDocument(signature: signature, at: finalPosition)
            
            // Small delay to ensure embedding is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.performSaveOperation()
            }
        } else {
            // No signature or already applied - proceed with save
            print("🚀 No pending signature - proceeding directly to save")
            performSaveOperation()
        }
    }
    
    private func performSaveOperation() {
        print("=== PERFORMING SAVE OPERATION ===")
        
        guard let pdfDocument = pdfDocument else {
            print("❌ ERROR: No PDF document available for save operation")
            DispatchQueue.main.async {
                self.saveMessage = "❌ Error: PDF document not available"
                self.showingSaveAlert = true
            }
            return
        }
        
        print("✅ PDF document ready for saving")
        print("📊 Document stats: \(pdfDocument.pageCount) pages")
        print("🏷️ Signature status: applied=\(hasAppliedSignature)")
        
        // Create new document name with appropriate suffix
        let timestamp = DateFormatter.fileNameFormatter.string(from: Date())
        let baseName = document.name.replacingOccurrences(of: ".pdf", with: "")
        let suffix = hasAppliedSignature ? "signed" : "edited"
        let newName = "\(baseName)_\(suffix)_\(timestamp).pdf"
        
        print("📄 Generated filename: \(newName)")
        
        // Save to documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        
        // Ensure directory exists
        do {
            try FileManager.default.createDirectory(at: pdfFolder, withIntermediateDirectories: true)
            print("✅ PDFs directory ready at: \(pdfFolder.path)")
        } catch {
            print("❌ Failed to create PDFs directory: \(error)")
            DispatchQueue.main.async {
                self.saveMessage = "❌ Error creating directory: \(error.localizedDescription)"
                self.showingSaveAlert = true
            }
            return
        }
        
        let newFileURL = pdfFolder.appendingPathComponent(newName)
        print("💾 Attempting to save to: \(newFileURL.path)")
        
        // Try to save the document
        let saveSuccess = pdfDocument.write(to: newFileURL)
        print("💾 Save operation result: \(saveSuccess ? "✅ SUCCESS" : "❌ FAILED")")
        
        DispatchQueue.main.async {
            if saveSuccess {
                print("🎉 PDF saved successfully!")
                
                // Verify file was created and get its size
                if FileManager.default.fileExists(atPath: newFileURL.path) {
                    print("✅ File verified on disk")
                    
                    // Create new document record with correct type
                    let documentType: PDFDocument.DocumentType = self.hasAppliedSignature ? .signed : .edited
                    let editedDocument = PDFDocument(
                        id: UUID(),
                        name: newName,
                        type: documentType,
                        size: self.calculateFileSize(from: newFileURL),
                        pages: pdfDocument.pageCount,
                        dateCreated: Date(),
                        thumbnailImage: nil
                    )
                    
                    print("📋 Document record created: \(editedDocument.name), type: \(editedDocument.type)")
                    
                    // Add to app state
                    self.appState.addDocument(editedDocument)
                    
                    // Show appropriate success message
                    let successMessage = self.hasAppliedSignature ? 
                        "✅ Документ подписан и сохранён! Подпись встроена в выбранном вами месте." :
                        "✅ Документ отредактирован и сохранён успешно!"
                    
                    self.saveMessage = successMessage
                    self.showingSaveAlert = true
                    
                    // Reset all signature-related state
                    self.isSignaturePlaced = false
                    self.hasAppliedSignature = false
                    self.signatureImage = nil
                    self.signaturePosition = .zero
                    self.signatureSize = .zero
                    self.signatureOffset = .zero
                    self.originalSignatureSize = .zero
                    self.currentViewGeometry = .zero
                    self.isDraggingSignature = false
                    self.showSignaturePulse = false
                    
                    print("🧹 Signature state cleared")
                    
                    // Reset saving state
                    self.isSaving = false
                    
                    // Auto-dismiss after showing success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        print("🚪 Auto-dismissing editor view")
                        self.dismiss()
                    }
                } else {
                    print("❌ File not found after save operation")
                    self.isSaving = false
                    self.saveMessage = "❌ Error: File could not be verified on disk"
                    self.showingSaveAlert = true
                }
            } else {
                print("❌ Save operation failed")
                self.isSaving = false
                self.saveMessage = "❌ Failed to save document. Please try again."
                self.showingSaveAlert = true
            }
        }
    }
    
    private func calculateFileSize(from url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[FileAttributeKey.size] as? Int64 {
                let sizeInKB = Double(size) / 1024.0
                
                if sizeInKB < 1024 {
                    return String(format: "%.0f KB", sizeInKB)
                } else {
                    return String(format: "%.1f MB", sizeInKB / 1024)
                }
            } else {
                return "Unknown"
            }
        } catch {
            return "Unknown"
        }
    }
    
    // MARK: - Signature Functions
    
    private func handleSignatureCreated(_ signature: UIImage) {
        print("=== SIGNATURE CREATED AND RECEIVED ===")
        print("📏 Signature size: \(signature.size)")
        print("🎯 Signature scale: \(signature.scale)")
        print("🖼️ Has alpha channel: \(signature.cgImage?.alphaInfo != CGImageAlphaInfo.none)")
        
        // Store the signature for interactive placement
        signatureImage = signature
        
        // Calculate optimal size maintaining aspect ratio
        let aspectRatio = signature.size.width / signature.size.height
        let maxWidth: CGFloat = 250
        let maxHeight: CGFloat = 120
        
        var width = maxWidth
        var height = maxWidth / aspectRatio
        
        if height > maxHeight {
            height = maxHeight
            width = maxHeight * aspectRatio
        }
        
        // Ensure reasonable minimum size for visibility
        width = max(width, 120)
        height = max(height, 60)
        
        let finalSize = CGSize(width: width, height: height)
        originalSignatureSize = finalSize  // Store original size for reset
        print("📐 Calculated display size: \(finalSize)")
        
        // Set initial position (safer center of view area)
        let initialPosition = CGPoint(x: 50, y: 150)
        print("📍 Initial position: \(initialPosition)")
        
        // Reset signature state
        signatureOffset = .zero
        isDraggingSignature = false
        showSignaturePulse = false
        
        // Initialize view geometry if not yet set
        if currentViewGeometry == .zero {
            currentViewGeometry = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 120)
            print("📱 Initialized view geometry to screen bounds: \(currentViewGeometry)")
        }
        
        // Animate signature appearance with smooth entrance
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0)) {
            signatureSize = finalSize
            signaturePosition = initialPosition
            isSignaturePlaced = true
            hasAppliedSignature = false  // Reset until actually applied
            
            // Set annotation mode to signature for proper interaction
            annotationMode = .signature
        }
        
        // Start pulsing animation to indicate signature can be moved
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSignaturePulse = true
        }
        
        // Enhanced haptic feedback for signature creation
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred(intensity: 0.8)
        
        // Show user guidance with delay for smooth presentation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.saveMessage = "✅ Подпись готова! Нажмите и перетащите её в нужное место. Зелёный контур показывает место сохранения в PDF."
            self.showingSaveAlert = true
            
            // Auto-hide guidance after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.showingSaveAlert = false
            }
        }
        
        print("✅ Signature placement initiated with smooth animation")
    }
    
// MARK: - Size Control Button Component
struct SizeControlButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .background(Circle().fill(color))
        }
    }
}

// MARK: - Animated Size Control Button Component
struct AnimatedSizeControlButton: View {
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            // Animate button press with smoother animation
            withAnimation(.interpolatingSpring(stiffness: 350, damping: 25)) {
                scale = 1.15
            }
            
            // Execute action
            action()
            
            // Return to normal size with smoother animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.interpolatingSpring(stiffness: 250, damping: 30)) {
                    scale = 1.0
                }
            }
        }) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? 
                                    [color.opacity(1.0), color.opacity(0.7)] :
                                    [color.opacity(0.8), color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.white.opacity(0.5) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(scale * (isSelected ? 1.1 : 1.0))
                .shadow(
                    color: color.opacity(0.4),
                    radius: isSelected ? 3 : 2,
                    x: 0,
                    y: isSelected ? 2 : 1
                )
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.interpolatingSpring(stiffness: 280, damping: 35), value: isSelected)
        .animation(.interpolatingSpring(stiffness: 320, damping: 30), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

    // Helper function for coordinate conversion testing
    private func debugCoordinateConversion(position: CGPoint, geometry: CGSize, pageBounds: CGRect) {
        print("🔍 === COORDINATE CONVERSION DEBUG ===")
        print("📱 Input position (screen): \(position)")
        print("📏 View geometry: \(geometry)")
        print("📄 Page bounds: \(pageBounds)")
        
        let viewHeight = geometry.height - 120 // minus toolbar
        let pageAspectRatio = pageBounds.width / pageBounds.height
        let viewAspectRatio = geometry.width / viewHeight
        
        var displayedWidth: CGFloat
        var displayedHeight: CGFloat
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        
        if pageAspectRatio > viewAspectRatio {
            displayedWidth = geometry.width
            displayedHeight = geometry.width / pageAspectRatio
            offsetY = (viewHeight - displayedHeight) / 2
        } else {
            displayedHeight = viewHeight
            displayedWidth = viewHeight * pageAspectRatio
            offsetX = (geometry.width - displayedWidth) / 2
        }
        
        let relativeX = (position.x - offsetX) / displayedWidth
        let relativeY = (position.y - offsetY) / displayedHeight
        
        print("📐 PDF display: W:\(displayedWidth), H:\(displayedHeight), offsetX:\(offsetX), offsetY:\(offsetY)")
        print("🎯 Relative position: X:\(relativeX), Y:\(relativeY)")
        print("📍 PDF coordinates: X:\(relativeX * pageBounds.width), Y:\(pageBounds.height - relativeY * pageBounds.height)")
        print("✅ === END COORDINATE DEBUG ===")
    }
    
    // MARK: - PDF Loading and Management
    private func handlePDFTap(at location: CGPoint) {
        print("PDF tapped at location: \(location)")
        // Handle PDF tap if needed - currently just logging
    }
    
    private func applySignatureToDocument(signature: UIImage, at position: CGPoint) {
        print("=== APPLYING SIGNATURE TO DOCUMENT ===")
        guard let pdfDocument = pdfDocument,
              let page = pdfDocument.page(at: currentPage) else {
            print("❌ ERROR: Failed to get PDF document or page")
            DispatchQueue.main.async {
                self.isSaving = false
                self.saveMessage = "❌ Error: Could not access PDF document"
                self.showingSaveAlert = true
            }
            return
        }
        
        print("✅ PDF page loaded successfully")
        let pageBounds = page.bounds(for: .mediaBox)
        print("📄 Page bounds: \(pageBounds)")
        print("📍 Original signature position: \(position)")
        print("📏 Signature size: \(signatureSize)")
        
        // Validate signature size
        guard signatureSize.width > 0 && signatureSize.height > 0 else {
            print("❌ Invalid signature size")
            DispatchQueue.main.async {
                self.isSaving = false
                self.saveMessage = "❌ Error: Invalid signature dimensions"
                self.showingSaveAlert = true
            }
            return
        }
        
        // Convert screen coordinates to PDF page coordinates
        // Account for the toolbar height that's not part of the PDF view
        let toolbarHeight: CGFloat = 120
        let adjustedPosition = CGPoint(
            x: position.x,
            y: position.y - toolbarHeight
        )
        
        // Debug coordinate conversion if we have view geometry
        if currentViewGeometry != .zero {
            debugCoordinateConversion(
                position: adjustedPosition, 
                geometry: currentViewGeometry, 
                pageBounds: pageBounds
            )
        }
        
        print("📍 Adjusted signature position: \(adjustedPosition)")
        
        // Embed signature permanently
        let success = embedSignaturePermanently(signature: signature, position: adjustedPosition, page: page)
        
        if success {
            print("✅ Successfully embedded signature into PDF")
            DispatchQueue.main.async {
                self.hasAppliedSignature = true
                self.isSignaturePlaced = false  // Clear overlay since signature is now embedded
                self.signatureOffset = .zero    // Reset offset
                self.isDraggingSignature = false // Reset dragging state
                self.showSignaturePulse = false  // Reset pulse animation
                print("✅ Signature state updated: applied=\(self.hasAppliedSignature), placed=\(self.isSignaturePlaced)")
                print("📍 Signature was embedded at position: \(adjustedPosition) with size: \(self.signatureSize)")
            }
        } else {
            print("❌ Failed to embed signature into PDF")
            DispatchQueue.main.async {
                self.isSaving = false
                self.saveMessage = "❌ Error: Failed to embed signature permanently"
                self.showingSaveAlert = true
            }
        }
    }
    
    private func embedSignaturePermanently(signature: UIImage, position: CGPoint, page: PDFPage) -> Bool {
        print("=== EMBEDDING SIGNATURE PERMANENTLY ===")
        
        let pageBounds = page.bounds(for: .mediaBox)
        print("📄 Page bounds: \(pageBounds)")
        print("📍 Input position: \(position)")
        print("📏 Signature size: \(signatureSize)")
        print("📱 Current view geometry: \(currentViewGeometry)")
        
        // Use the actual view geometry instead of screen bounds
        let viewWidth = currentViewGeometry.width > 0 ? currentViewGeometry.width : UIScreen.main.bounds.width
        let viewHeight = (currentViewGeometry.height > 0 ? currentViewGeometry.height : UIScreen.main.bounds.height) - 120 // minus toolbar
        
        print("📐 Using view dimensions - W: \(viewWidth), H: \(viewHeight)")
        
        // Calculate how the PDF is displayed within the view
        let pageAspectRatio = pageBounds.width / pageBounds.height
        let viewAspectRatio = viewWidth / viewHeight
        
        var displayedWidth: CGFloat
        var displayedHeight: CGFloat
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        
        if pageAspectRatio > viewAspectRatio {
            // PDF is wider than view aspect ratio - fit to width
            displayedWidth = viewWidth
            displayedHeight = viewWidth / pageAspectRatio
            offsetY = (viewHeight - displayedHeight) / 2
        } else {
            // PDF is taller than view aspect ratio - fit to height  
            displayedHeight = viewHeight
            displayedWidth = viewHeight * pageAspectRatio
            offsetX = (viewWidth - displayedWidth) / 2
        }
        
        print("📐 PDF display dimensions - W: \(displayedWidth), H: \(displayedHeight)")
        print("📐 PDF display offset - X: \(offsetX), Y: \(offsetY)")
        
        // Convert view coordinates to PDF coordinates with proper bounds checking
        let relativeX = max(0, min(1, (position.x - offsetX) / displayedWidth))
        let relativeY = max(0, min(1, (position.y - offsetY) / displayedHeight))
        
        let pdfX = relativeX * pageBounds.width
        let pdfY = pageBounds.height - (relativeY * pageBounds.height) - (signatureSize.height / displayedHeight * pageBounds.height)
        
        // Calculate signature size in PDF coordinates
        let pdfSignatureWidth = (signatureSize.width / displayedWidth) * pageBounds.width
        let pdfSignatureHeight = (signatureSize.height / displayedHeight) * pageBounds.height
        
        // Ensure signature stays within page bounds
        let finalPdfX = max(10, min(pdfX, pageBounds.width - pdfSignatureWidth - 10))
        let finalPdfY = max(10, min(pdfY, pageBounds.height - pdfSignatureHeight - 10))
        let finalWidth = min(pdfSignatureWidth, pageBounds.width - 20)
        let finalHeight = min(pdfSignatureHeight, pageBounds.height - 20)
        
        let signatureRect = CGRect(
            x: finalPdfX,
            y: finalPdfY,
            width: finalWidth,
            height: finalHeight
        )
        
        print("📐 Final signature rect in PDF coordinates: \(signatureRect)")
        print("📊 Relative position - X: \(relativeX), Y: \(relativeY)")
        print("🎯 PDF position - X: \(finalPdfX), Y: \(finalPdfY)")
        
        // Create a new PDF context to draw the page with signature
        let renderer = UIGraphicsImageRenderer(bounds: pageBounds)
        let combinedImage = renderer.image { context in
            let cgContext = context.cgContext
            
            // Fill with white background
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(pageBounds)
            
            // Draw the original PDF page content
            cgContext.saveGState()
            cgContext.translateBy(x: 0, y: pageBounds.height)
            cgContext.scaleBy(x: 1, y: -1)
            
            let pageDrawn = page.thumbnail(of: pageBounds.size, for: .mediaBox)
            pageDrawn.draw(at: .zero)
            cgContext.restoreGState()
            
            // Draw the signature at the calculated position
            cgContext.saveGState()
            signature.draw(in: signatureRect)
            cgContext.restoreGState()
            
            print("✅ Signature drawn at: \(signatureRect)")
        }
        
        // Replace the page content with the combined image
        let success = replacePageWithImage(page: page, image: combinedImage)
        print("🔄 Page replacement result: \(success)")
        
        return success
    }
    
    private func replacePageWithImage(page: PDFPage, image: UIImage) -> Bool {
        print("=== REPLACING PAGE WITH IMAGE ===")
        
        guard let pdfDocument = pdfDocument else {
            print("❌ No PDF document available")
            return false
        }
        
        let pageBounds = page.bounds(for: .mediaBox)
        
        // Create new PDF data with the image
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageBounds, nil)
        UIGraphicsBeginPDFPage()
        
        // Get current graphics context
        guard let context = UIGraphicsGetCurrentContext() else {
            print("❌ Failed to get graphics context")
            UIGraphicsEndPDFContext()
            return false
        }
        
        // Draw the image into PDF context
        context.saveGState()
        context.translateBy(x: 0, y: pageBounds.height)
        context.scaleBy(x: 1, y: -1)
        image.draw(in: pageBounds)
        context.restoreGState()
        
        UIGraphicsEndPDFContext()
        
        // Create new PDF document from the data
        guard let newPDFDocument = PDFKit.PDFDocument(data: pdfData as Data),
              let newPage = newPDFDocument.page(at: 0) else {
            print("❌ Failed to create new PDF document")
            return false
        }
        
        // Replace the current page
        let pageIndex = currentPage
        pdfDocument.removePage(at: pageIndex)
        pdfDocument.insert(newPage, at: pageIndex)
        
        print("✅ Successfully replaced page with signature")
        return true
    }
}

// MARK: - PDF Editor Content View
struct PDFEditorContentView: UIViewRepresentable {
    let pdfDocument: PDFKit.PDFDocument
    @Binding var currentPage: Int
    @Binding var annotationMode: PDFEditorView.AnnotationMode
    let onTap: ((CGPoint) -> Void)?
    
    init(pdfDocument: PDFKit.PDFDocument,
         currentPage: Binding<Int>,
         annotationMode: Binding<PDFEditorView.AnnotationMode>,
         onTap: ((CGPoint) -> Void)? = nil) {
        self.pdfDocument = pdfDocument
        self._currentPage = currentPage
        self._annotationMode = annotationMode
        self.onTap = onTap
    }
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemGray6
        
        // Set up delegate
        pdfView.delegate = context.coordinator
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        pdfView.addGestureRecognizer(tapGesture)
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if pdfView.document != pdfDocument {
            pdfView.document = pdfDocument
        }
        
        // Update annotation mode in coordinator
        context.coordinator.annotationMode = annotationMode
        context.coordinator.onTap = onTap
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        let parent: PDFEditorContentView
        var annotationMode: PDFEditorView.AnnotationMode = .none
        var onTap: ((CGPoint) -> Void)?
        
        init(_ parent: PDFEditorContentView) {
            self.parent = parent
        }
        
        // Handle page changes
        func pdfViewPageChanged(_ sender: PDFView) {
            if let currentPage = sender.currentPage,
               let document = sender.document {
                parent.currentPage = document.index(for: currentPage)
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let pdfView = gesture.view as? PDFView else { return }
            
            let location = gesture.location(in: pdfView)
            
            // Convert the tap location to PDF coordinate system
            if let page = pdfView.currentPage {
                let convertedLocation = pdfView.convert(location, to: page)
                onTap?(convertedLocation)
            }
        }
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let icon: String
    let isSelected: Bool
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .frame(width: 50, height: 50)
                .background(Color.white)
                .background(gradient.opacity(isSelected ? 1 : 0))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.white.opacity(0.3) : AppColors.textSecondary.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: AppColors.shadowColor, radius: isSelected ? 6 : 3, x: 0, y: isSelected ? 4 : 2)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Signature Pad View
struct SignaturePadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()
    @State private var hasDrawing = false
    let onSignatureComplete: (UIImage) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header section with improved styling
                VStack(spacing: 12) {
                    Text("Create Your Signature")
                        .font(AppFonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 8)
                    
                    Text("Use your finger or Apple Pencil to draw your digital signature")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 20)
                }
                
                // Canvas for drawing with improved styling
                VStack(spacing: 12) {
                    // Canvas area with enhanced design
                    ZStack {
                        // Background with gradient
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color.gray.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
                        
                        // Border with dynamic color based on drawing state
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                hasDrawing ? 
                                LinearGradient(
                                    colors: [AppColors.primaryBlue.opacity(0.6), AppColors.accentBlue.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: hasDrawing ? 3 : 2
                            )
                            .animation(.easeInOut(duration: 0.3), value: hasDrawing)
                        
                        // Canvas content
                        SignatureCanvasView(
                            canvasView: $canvasView,
                            hasDrawing: $hasDrawing
                        )
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        // Placeholder text when no drawing
                        if !hasDrawing {
                            VStack(spacing: 8) {
                                Image(systemName: "pencil.and.scribble")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.primaryBlue.opacity(0.3))
                                
                                Text("Sign here")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            }
                            .opacity(0.6)
                            .animation(.easeInOut(duration: 0.3), value: hasDrawing)
                        }
                    }
                    .frame(height: 240)
                    .padding(.horizontal, 20)
                    
                    // Status indicator
                    HStack {
                        Circle()
                            .fill(hasDrawing ? Color.green : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: hasDrawing)
                        
                        Text(hasDrawing ? "Signature ready" : "Draw your signature above")
                            .font(AppFonts.small)
                            .foregroundColor(hasDrawing ? Color.green : AppColors.textSecondary)
                            .animation(.easeInOut(duration: 0.2), value: hasDrawing)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                
                // Action buttons with improved animations
                VStack(spacing: 16) {
                    // Main action button
                    Button("Save Signature") {
                        print("Save Signature button tapped, hasDrawing: \(hasDrawing)")
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        // Execute capture immediately
                        captureSignature()
                    }
                    .font(AppFonts.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Group {
                            if hasDrawing {
                                // Beautiful gradient for active state
                                LinearGradient(
                                    colors: [
                                        AppColors.primaryBlue,
                                        Color(red: 0.0, green: 0.4, blue: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                // Subtle gradient for inactive state
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                hasDrawing ? 
                                AppColors.primaryBlue.opacity(0.3) : 
                                Color.gray.opacity(0.2), 
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: hasDrawing ? 
                        AppColors.primaryBlue.opacity(0.4) : 
                        Color.gray.opacity(0.3),
                        radius: hasDrawing ? 8 : 4,
                        x: 0,
                        y: hasDrawing ? 4 : 2
                    )
                    .scaleEffect(hasDrawing ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasDrawing)
                    
                    // Secondary action button
                    Button("Clear Canvas") {
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        // Execute clear immediately, don't wrap in animation
                        clearCanvas()
                    }
                    .font(AppFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .opacity(hasDrawing ? 1.0 : 0.7)
                    .animation(.easeInOut(duration: 0.2), value: hasDrawing)
                }
                .padding(.bottom)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.primaryBlue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.primaryBlue.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(AppColors.primaryBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use Default") {
                        print("=== Use Default button tapped ===")
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        createDefaultSignature()
                    }
                    .font(AppFonts.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.accentBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: AppColors.primaryBlue.opacity(0.3),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                }
            }
        }
        .onAppear {
            setupCanvas()
        }
    }
    
    private func setupCanvas() {
        print("Setting up canvas...")
        canvasView.backgroundColor = UIColor.clear
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.drawingPolicy = .anyInput
        canvasView.alwaysBounceVertical = false
        canvasView.alwaysBounceHorizontal = false
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
        canvasView.isUserInteractionEnabled = true
        
        print("Canvas setup completed")
    }
    
    private func clearCanvas() {
        print("=== CLEARING CANVAS ===")
        
        DispatchQueue.main.async {
            self.canvasView.drawing = PKDrawing()
            self.hasDrawing = false
            print("Canvas cleared - hasDrawing: \(self.hasDrawing)")
        }
    }
    
    private func captureSignature() {
        print("=== CAPTURE SIGNATURE START ===")
        print("Canvas strokes count: \(canvasView.drawing.strokes.count)")
        print("HasDrawing state: \(hasDrawing)")
        
        // Ensure we're on main thread
        DispatchQueue.main.async {
            // Always try to capture, even if hasDrawing is false
            let bounds = self.canvasView.bounds.isEmpty ? CGRect(x: 0, y: 0, width: 300, height: 200) : self.canvasView.bounds
            
            print("Using bounds: \(bounds)")
            
            if !self.canvasView.drawing.strokes.isEmpty {
                // Use actual drawing
                let image = self.canvasView.drawing.image(from: bounds, scale: UIScreen.main.scale)
                print("Generated image from drawing, size: \(image.size)")
                
                if image.size.width > 0 && image.size.height > 0 {
                    print("Using signature image")
                    self.onSignatureComplete(image)
                    self.dismiss()
                    return
                }
            }
            
            // Fallback: create default signature
            print("Using fallback signature")
            self.createDefaultSignature()
        }
    }
    
    private func createDefaultSignature() {
        print("=== CREATING DEFAULT SIGNATURE ===")
        
        DispatchQueue.main.async {
            let size = CGSize(width: 250, height: 100)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                let cgContext = context.cgContext
                
                // Set up drawing parameters
                cgContext.setStrokeColor(UIColor.black.cgColor)
                cgContext.setLineWidth(3.0)
                cgContext.setLineCap(.round)
                cgContext.setLineJoin(.round)
                
                // Draw a signature-like curve
                cgContext.beginPath()
                cgContext.move(to: CGPoint(x: 30, y: 60))
                cgContext.addCurve(to: CGPoint(x: 220, y: 50),
                                  control1: CGPoint(x: 80, y: 30),
                                  control2: CGPoint(x: 170, y: 80))
                cgContext.strokePath()
                
                // Add a flourish
                cgContext.beginPath()
                cgContext.move(to: CGPoint(x: 200, y: 55))
                cgContext.addCurve(to: CGPoint(x: 240, y: 45),
                                  control1: CGPoint(x: 220, y: 40),
                                  control2: CGPoint(x: 235, y: 60))
                cgContext.strokePath()
                
                // Add decorative underline
                cgContext.beginPath()
                cgContext.move(to: CGPoint(x: 40, y: 80))
                cgContext.addLine(to: CGPoint(x: 210, y: 80))
                cgContext.setLineWidth(1.5)
                cgContext.strokePath()
            }
            
            print("Default signature created, size: \(image.size)")
            print("Calling onSignatureComplete...")
            self.onSignatureComplete(image)
            
            print("Dismissing view...")
            self.dismiss()
        }
    }
}

// MARK: - Signature Canvas View
    
    private func trimTransparentEdges(image: UIImage) -> UIImage? {
        print("Attempting to trim transparent edges...")
        
        guard let cgImage = image.cgImage else { 
            print("Failed to get cgImage")
            return nil 
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Simple fallback if image is too large to process efficiently
        if width * height > 1000000 {
            print("Image too large for trimming, using original")
            return image
        }
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitmapByteCount = bytesPerRow * height
        
        let bitmapData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
        defer { bitmapData.deallocate() }
        
        guard let context = CGContext(
            data: bitmapData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { 
            print("Failed to create context")
            return nil 
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var minX = width
        var maxX = 0
        var minY = height
        var maxY = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let alpha = bitmapData[pixelIndex + 3]
                
                if alpha > 0 {
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                    minY = min(minY, y)
                    maxY = max(maxY, y)
                }
            }
        }
        
        guard minX < maxX && minY < maxY else { 
            print("No non-transparent pixels found")
            return nil 
        }
        
        let trimmedRect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        print("Trimmed rect: \(trimmedRect)")
        
        if let trimmedCGImage = cgImage.cropping(to: trimmedRect) {
            let trimmedImage = UIImage(cgImage: trimmedCGImage)
            print("Successfully trimmed image to size: \(trimmedImage.size)")
            return trimmedImage
        }
        
        print("Failed to crop image")
        return nil
    }

// MARK: - Signature Canvas View
struct SignatureCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var hasDrawing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        print("Creating PKCanvasView")
        
        // Configure canvas view
        canvasView.backgroundColor = UIColor.clear
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.drawingPolicy = .anyInput
        canvasView.alwaysBounceVertical = false
        canvasView.alwaysBounceHorizontal = false
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
        canvasView.isUserInteractionEnabled = true
        
        // Set up delegate to track changes
        canvasView.delegate = context.coordinator
        
        print("PKCanvasView configured successfully")
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Ensure the canvas tool is set correctly
        uiView.tool = PKInkingTool(.pen, color: .black, width: 3)
        
        // Update delegate
        uiView.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: SignatureCanvasView
        
        init(_ parent: SignatureCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            print("Canvas drawing changed, strokes: \(canvasView.drawing.strokes.count)")
            DispatchQueue.main.async {
                self.parent.hasDrawing = !canvasView.drawing.strokes.isEmpty
                print("Updated hasDrawing to: \(self.parent.hasDrawing)")
            }
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            print("User began drawing")
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            print("User finished drawing")
            DispatchQueue.main.async {
                self.parent.hasDrawing = !canvasView.drawing.strokes.isEmpty
            }
        }
    }
}

// MARK: - Resizable Signature Overlay View (Simplified)
struct ResizableSignatureOverlayView: View {
    let image: UIImage
    let position: CGPoint
    let size: CGSize
    let offset: CGSize
    let screenSize: CGSize
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    let onSizeChanged: (CGSize) -> Void
    
    @State private var isResizing = false
    @State private var maintainAspectRatio = true
    @State private var currentSize: CGSize = .zero
    @State private var isDragging = false    // Track dragging state for visual feedback
    
    private let minSize: CGSize = CGSize(width: 60, height: 30)
    private let maxSize: CGSize = CGSize(width: 300, height: 150)
    
    var body: some View {
        VStack(spacing: 0) {
            // Main signature container with expanded touch area
            ZStack {
                // Expanded touch area for dragging
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if !isDragging {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)) {
                                        isDragging = true
                                    }
                                }
                                onDragChanged(value)
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                                    isDragging = false
                                }
                                onDragEnded(value)
                            }
                    )
                
                // Signature image with border
                VStack(spacing: 0) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: currentSize.width, height: currentSize.height)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.blue.opacity(
                                        isDragging ? 1.0 : (isResizing ? 1.0 : 0.8)
                                    ), 
                                    lineWidth: isDragging ? 3 : (isResizing ? 3 : 2)
                                )
                                .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: isDragging)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: isResizing)
                        )
                        .scaleEffect(isDragging ? 1.05 : (isResizing ? 1.02 : 1.0))
                        .shadow(
                            color: .black.opacity(isDragging ? 0.3 : 0.1), 
                            radius: isDragging ? 8 : 4, 
                            x: 0, 
                            y: isDragging ? 4 : 2
                        )
                    
                    // Resize control bar
                    if isResizing {
                        resizeControlBar
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            ))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(isDragging ? 0.25 : (isResizing ? 0.2 : 0.1)))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isDragging)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: isResizing)
                )
                
                // Enhanced resize handle in bottom-right corner
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        resizeHandle
                    }
                }
            }
            .frame(width: currentSize.width + 120, height: currentSize.height + 120)
        }
        .offset(x: position.x + offset.width, y: position.y + offset.height)
        .onAppear {
            currentSize = size
        }
        .onChange(of: size) { newSize in
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 35)) {
                currentSize = newSize
            }
        }
    }
    
    private var resizeHandle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: isResizing ? 
                            [Color.blue.opacity(0.9), Color.blue.opacity(0.7)] :
                            [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: isResizing ? 28 : 24, height: isResizing ? 28 : 24)
                .shadow(color: .black.opacity(0.3), radius: isResizing ? 6 : 4, x: 2, y: 2)
            
            Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                .font(.system(size: isResizing ? 12 : 10, weight: .bold))
                .foregroundColor(.white)
                .rotationEffect(.degrees(isResizing ? 5 : 0))
        }
        .scaleEffect(isResizing ? 1.1 : 1.0)
        .animation(.interpolatingSpring(stiffness: 250, damping: 30), value: isResizing)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isResizing {
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 35)) {
                            isResizing = true
                        }
                    }
                    
                    // Smoother resize calculation with smaller increments
                    let sensitivity: CGFloat = 0.8
                    let widthChange = value.translation.width * sensitivity
                    let heightChange = value.translation.height * sensitivity
                    
                    let newWidth = max(minSize.width, min(maxSize.width, size.width + widthChange))
                    
                    if maintainAspectRatio {
                        let aspectRatio = size.width / size.height
                        let newHeight = newWidth / aspectRatio
                        let constrainedHeight = max(minSize.height, min(maxSize.height, newHeight))
                        
                        let newSize = CGSize(width: newWidth, height: constrainedHeight)
                        onSizeChanged(newSize)
                    } else {
                        let newHeight = max(minSize.height, min(maxSize.height, size.height + heightChange))
                        let newSize = CGSize(width: newWidth, height: newHeight)
                        onSizeChanged(newSize)
                    }
                    
                    // Reduced haptic feedback frequency
                    let translationSum = abs(value.translation.width) + abs(value.translation.height)
                    if Int(translationSum) % 8 == 0 {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred(intensity: 0.3)
                    }
                }
                .onEnded { _ in
                    withAnimation(.interpolatingSpring(stiffness: 280, damping: 35)) {
                        isResizing = false
                    }
                    
                    // Completion feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred(intensity: 0.6)
                }
        )
    }
    
    private var resizeControlBar: some View {
        HStack(spacing: 12) {
            // Size display with animation
            Text("\(Int(currentSize.width)) × \(Int(currentSize.height))")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .contentTransition(.numericText())
            
            Divider()
                .frame(height: 12)
            
            // Aspect ratio lock toggle with smooth animation
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 220, damping: 30)) {
                    maintainAspectRatio.toggle()
                }
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                Image(systemName: maintainAspectRatio ? "lock.fill" : "lock.open.fill")
                    .font(.caption2)
                    .foregroundColor(maintainAspectRatio ? .blue : .gray)
                    .scaleEffect(maintainAspectRatio ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 600, damping: 20), value: maintainAspectRatio)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(isResizing ? 1.0 : 0.95)
        .animation(.interpolatingSpring(stiffness: 400, damping: 25), value: isResizing)
    }
}

// MARK: - Original Signature Overlay View (kept for compatibility)
struct SignatureOverlayView: View {
    let image: UIImage
    let position: CGPoint
    let size: CGSize
    let offset: CGSize
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: size.width, height: size.height)
            .position(x: position.x + size.width/2 + offset.width, 
                     y: position.y + size.height/2 + offset.height)
            .gesture(
                DragGesture()
                    .onChanged(onDragChanged)
                    .onEnded(onDragEnded)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.7), lineWidth: 2)
                    .frame(width: size.width, height: size.height)
                    .position(x: position.x + size.width/2 + offset.width, 
                             y: position.y + size.height/2 + offset.height)
            )
            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
    }
}

// MARK: - Simple Signature Pad (Fallback)
struct SimpleSignaturePadView: View {
    @Environment(\.dismiss) private var dismiss
    let onSignatureComplete: (UIImage) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Create Signature")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Choose how to create your signature")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    Button("Use Default Signature") {
                        createDefaultSignature()
                    }
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(AppColors.signGradient)
                    .cornerRadius(25)
                    
                    Button("Create Custom Text") {
                        createTextSignature()
                    }
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.primaryBlue)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(25)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
        }
    }
    
    private func createDefaultSignature() {
        let size = CGSize(width: 200, height: 80)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            // Set up drawing parameters
            cgContext.setStrokeColor(UIColor.black.cgColor)
            cgContext.setLineWidth(3.0)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)
            
            // Draw a signature-like curve
            cgContext.beginPath()
            cgContext.move(to: CGPoint(x: 20, y: 45))
            cgContext.addCurve(to: CGPoint(x: 180, y: 35),
                              control1: CGPoint(x: 70, y: 20),
                              control2: CGPoint(x: 130, y: 60))
            cgContext.strokePath()
            
            // Add decorative underline
            cgContext.beginPath()
            cgContext.move(to: CGPoint(x: 30, y: 65))
            cgContext.addLine(to: CGPoint(x: 170, y: 65))
            cgContext.setLineWidth(1.5)
            cgContext.strokePath()
        }
        
        onSignatureComplete(image)
        dismiss()
    }
    
    private func createTextSignature() {
        let size = CGSize(width: 200, height: 60)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let text = "Digital Signature"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Snell Roundhand", size: 24) ?? UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textRect = CGRect(x: 10, y: 15, width: 180, height: 40)
            
            attributedString.draw(in: textRect)
        }
        
        onSignatureComplete(image)
        dismiss()
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}
