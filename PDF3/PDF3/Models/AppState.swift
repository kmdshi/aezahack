import SwiftUI
import Foundation

// Импорт для доступа к WidgetDataProvider
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - Main App State
class AppState: ObservableObject {
    @Published var isOnboardingComplete: Bool = false
    @Published var currentTab: AppTab = .home
    @Published var documents: [PDFDocument] = []
    @Published var recentActivity: [ActivityItem] = []
    @Published var conversionCount: Int = 0
    @Published var isPremium: Bool = false
    
    private let maxFreeConversions = 5
    
    init() {
        setupDocumentsDirectory()
        loadConversionCount()
        loadDocumentsAndActivity()
        
        // Инициализируем данные виджетов при загрузке приложения
        DispatchQueue.main.async {
            self.updateWidgetData()
        }
    }
    
    // MARK: - Premium Logic
    func canPerformConversion() -> Bool {
        return isPremium || conversionCount < maxFreeConversions
    }
    
    func incrementConversionCount() {
        conversionCount += 1
        saveConversionCount()
    }
    
    func shouldShowPaywall() -> Bool {
        return !isPremium && conversionCount >= maxFreeConversions
    }
    
    func upgradeToPremiun() {
        isPremium = true
        // Save premium status to UserDefaults
        UserDefaults.standard.set(true, forKey: "isPremium")
    }
    
    private func loadConversionCount() {
        conversionCount = UserDefaults.standard.integer(forKey: "conversionCount")
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
    }
    
    private func saveConversionCount() {
        UserDefaults.standard.set(conversionCount, forKey: "conversionCount")
    }
    
    private func saveDocuments() {
        if let encoded = try? JSONEncoder().encode(documents) {
            UserDefaults.standard.set(encoded, forKey: "savedDocuments")
        }
    }
    
    private func saveRecentActivity() {
        if let encoded = try? JSONEncoder().encode(recentActivity) {
            UserDefaults.standard.set(encoded, forKey: "savedActivity")
        }
    }
    
    private func loadDocumentsAndActivity() {
        // Load documents
        if let data = UserDefaults.standard.data(forKey: "savedDocuments"),
           let decodedDocuments = try? JSONDecoder().decode([PDFDocument].self, from: data) {
            self.documents = decodedDocuments
        }
        
        // Load recent activity
        if let data = UserDefaults.standard.data(forKey: "savedActivity"),
           let decodedActivity = try? JSONDecoder().decode([ActivityItem].self, from: data) {
            self.recentActivity = decodedActivity
        }
    }
    
    private func setupDocumentsDirectory() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        
        if !FileManager.default.fileExists(atPath: pdfFolder.path) {
            try? FileManager.default.createDirectory(at: pdfFolder, withIntermediateDirectories: true)
        }
    }
    
    private func loadSampleData() {
        // No sample data - start with empty state
        documents = []
        recentActivity = []
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
    }
    
    func addDocument(_ document: PDFDocument) {
        documents.insert(document, at: 0)
        
        // Add activity
        let activity = ActivityItem(
            id: UUID(),
            type: ActivityItem.ActivityType(document.type),
            title: document.type.activityTitle,
            description: "\(document.name) \(document.type.activityDescription)",
            timestamp: Date()
        )
        recentActivity.insert(activity, at: 0)
        
        // Keep only last 20 activities
        if recentActivity.count > 20 {
            recentActivity = Array(recentActivity.prefix(20))
        }
        
        // Save changes
        saveDocuments()
        saveRecentActivity()
        
        // Обновляем статистику виджетов при добавлении документа
        onDocumentCreated(document)
    }
    
    func deleteDocument(_ document: PDFDocument) {
        documents.removeAll { $0.id == document.id }
        
        // Delete physical file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        let fileURL = pdfFolder.appendingPathComponent(document.name)
        
        try? FileManager.default.removeItem(at: fileURL)
        
        // Save changes
        saveDocuments()
        
        // Обновляем данные виджетов при удалении документа (без уменьшения накопительной статистики)
        onDocumentDeleted(document)
    }
    
    func getPDFPath(for document: PDFDocument) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfFolder = documentsPath.appendingPathComponent("PDFs")
        return pdfFolder.appendingPathComponent(document.name)
    }
    
    func createEditedDocument(from originalDocument: PDFDocument, editedName: String, editedSize: String, pageCount: Int) -> PDFDocument {
        let editedDocument = PDFDocument(
            id: UUID(),
            name: editedName,
            type: .edited,
            size: editedSize,
            pages: pageCount,
            dateCreated: Date(),
            thumbnailImage: nil
        )
        
        addDocument(editedDocument)
        return editedDocument
    }
    
    func canEditDocument(_ document: PDFDocument) -> Bool {
        // Allow editing of all document types except already edited ones
        return true
    }
    
    func createSignedDocument(from originalDocument: PDFDocument, signedName: String, signedSize: String, pageCount: Int) -> PDFDocument {
        let signedDocument = PDFDocument(
            id: UUID(),
            name: signedName,
            type: .signed,
            size: signedSize,
            pages: pageCount,
            dateCreated: Date(),
            thumbnailImage: nil
        )
        
        addDocument(signedDocument)
        return signedDocument
    }
    
    func canSignDocument(_ document: PDFDocument) -> Bool {
        // Allow signing of all document types
        return true
    }
}

// MARK: - App Tabs (Single Home Page)
enum AppTab: String, CaseIterable {
    case home = "home"
}

// MARK: - PDF Document Model
struct PDFDocument: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: DocumentType
    let size: String
    let pages: Int
    let dateCreated: Date
    let thumbnailImage: String?
    
    enum DocumentType: Codable {
        case scanned
        case converted
        case edited
        case signed
        
        var icon: String {
            switch self {
            case .scanned: return "camera.fill"
            case .converted: return "arrow.triangle.2.circlepath"
            case .edited: return "pencil"
            case .signed: return "signature"
            }
        }
        
        var color: Color {
            switch self {
            case .scanned: return AppColors.scanColor
            case .converted: return AppColors.convertColor
            case .edited: return AppColors.editColor
            case .signed: return AppColors.signColor
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .scanned: return AppColors.scanGradient
            case .converted: return AppColors.convertGradient
            case .edited: return AppColors.editGradient
            case .signed: return AppColors.signGradient
            }
        }
        
        var activityTitle: String {
            switch self {
            case .scanned: return "Document Scanned"
            case .converted: return "File Converted"
            case .edited: return "Document Edited"
            case .signed: return "Document Signed"
            }
        }
        
        var activityDescription: String {
            switch self {
            case .scanned: return "scanned successfully"
            case .converted: return "converted to PDF"
            case .edited: return "edited and saved"
            case .signed: return "signed digitally"
            }
        }
    }
}

// MARK: - Activity Item Model
struct ActivityItem: Identifiable, Codable {
    let id: UUID
    let type: ActivityType
    let title: String
    let description: String
    let timestamp: Date
    
    enum ActivityType: Codable {
        case scanned
        case converted
        case edited
        case signed
        case merged
        case shared
        
        var icon: String {
            switch self {
            case .scanned: return "camera.fill"
            case .converted: return "arrow.triangle.2.circlepath"
            case .edited: return "pencil"
            case .signed: return "signature"
            case .merged: return "doc.on.doc.fill"
            case .shared: return "square.and.arrow.up"
            }
        }
        
        var color: Color {
            switch self {
            case .scanned: return AppColors.scanColor
            case .converted: return AppColors.convertColor
            case .edited: return AppColors.editColor
            case .signed: return AppColors.signColor
            case .merged: return AppColors.accentBlue
            case .shared: return AppColors.primaryBlue
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .scanned: return AppColors.scanGradient
            case .converted: return AppColors.convertGradient
            case .edited: return AppColors.editGradient
            case .signed: return AppColors.signGradient
            case .merged: return AppColors.lightGradient
            case .shared: return AppColors.primaryGradient
            }
        }
    }
}

extension ActivityItem.ActivityType {
    init(_ documentType: PDFDocument.DocumentType) {
        switch documentType {
        case .scanned: self = .scanned
        case .converted: self = .converted
        case .edited: self = .edited
        case .signed: self = .signed
        }
    }
}

// MARK: - Widget Integration Extension
extension AppState {
    
    // Простая структура для хранения данных виджетов внутри основного приложения
    private struct WidgetDocumentData: Codable {
        let id: String
        let name: String
        let date: Date
        let pageCount: Int
        let fileSize: Int64
        let filePath: String
    }
    
    private struct WidgetStatistics {
        let totalDocuments: Int
        let todayDocuments: Int
        let totalPages: Int
    }
    
    // Простой класс для управления статистикой виджетов
    private class SimpleWidgetDataProvider {
        static let shared = SimpleWidgetDataProvider()
        
        private let userDefaults = UserDefaults(suiteName: "group.com.example.myapp.widgets")
        
        private struct Keys {
            static let recentDocuments = "recentDocuments"
            static let totalDocuments = "totalDocuments"
            static let todayDocuments = "todayDocuments"
            static let totalPages = "totalPages"
            static let lastUpdate = "lastUpdate"
            static let allTimeDocuments = "allTimeDocuments"
            static let allTimePages = "allTimePages"
        }
        
        private init() {}
        
        func updateRecentDocuments(_ documents: [WidgetDocumentData]) {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(documents) {
                userDefaults?.set(data, forKey: Keys.recentDocuments)
                userDefaults?.set(Date(), forKey: Keys.lastUpdate)
            }
            
            // Обновляем только показатель документов за сегодня (он может уменьшаться)
            let todayDocuments = documents.filter { Calendar.current.isDateInToday($0.date) }.count
            userDefaults?.set(todayDocuments, forKey: Keys.todayDocuments)
        }
        
        func addDocumentToStatistics(pageCount: Int) {
            guard let userDefaults = userDefaults else { return }
            
            // Увеличиваем общее количество документов за все время
            let currentAllTimeDocuments = userDefaults.integer(forKey: Keys.allTimeDocuments)
            userDefaults.set(currentAllTimeDocuments + 1, forKey: Keys.allTimeDocuments)
            
            // Увеличиваем общее количество страниц за все время  
            let currentAllTimePages = userDefaults.integer(forKey: Keys.allTimePages)
            userDefaults.set(currentAllTimePages + pageCount, forKey: Keys.allTimePages)
            
            // Обновляем отображаемую статистику
            updateDisplayStatistics()
        }
        
        func initializeStatisticsIfNeeded(currentDocuments: [WidgetDocumentData]) {
            guard let userDefaults = userDefaults else { return }
            
            // Проверяем, была ли уже инициализирована накопительная статистика
            if userDefaults.object(forKey: Keys.allTimeDocuments) == nil {
                // Инициализируем на основе текущих документов
                let totalDocs = currentDocuments.count
                let totalPages = currentDocuments.reduce(0) { $0 + $1.pageCount }
                
                userDefaults.set(totalDocs, forKey: Keys.allTimeDocuments)
                userDefaults.set(totalPages, forKey: Keys.allTimePages)
                
                updateDisplayStatistics()
            }
        }
        
        private func updateDisplayStatistics() {
            guard let userDefaults = userDefaults else { return }
            
            let allTimeDocuments = userDefaults.integer(forKey: Keys.allTimeDocuments)
            let allTimePages = userDefaults.integer(forKey: Keys.allTimePages)
            let todayDocuments = userDefaults.integer(forKey: Keys.todayDocuments)
            
            // Используем накопительную статистику для отображения
            userDefaults.set(allTimeDocuments, forKey: Keys.totalDocuments)
            userDefaults.set(allTimePages, forKey: Keys.totalPages)
        }
        
        func refreshWidgets() {
            // Уведомляем виджеты об обновлении данных
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
    
    // Метод для обновления данных виджетов при изменении документов
    func updateWidgetData() {
        let widgetDocs = documents.map { doc in
            WidgetDocumentData(
                id: doc.id.uuidString,
                name: doc.name,
                date: doc.dateCreated,
                pageCount: doc.pages,
                fileSize: calculateFileSize(for: doc),
                filePath: doc.name // Используем имя файла как путь
            )
        }
        
        // Сортируем по дате создания (новые сначала)
        let sortedDocs = widgetDocs.sorted { $0.date > $1.date }
        
        // Инициализируем накопительную статистику при первом запуске
        SimpleWidgetDataProvider.shared.initializeStatisticsIfNeeded(currentDocuments: widgetDocs)
        
        // Обновляем список последних документов и документы за сегодня
        SimpleWidgetDataProvider.shared.updateRecentDocuments(Array(sortedDocs.prefix(10)))
        
        // Обновляем виджеты
        SimpleWidgetDataProvider.shared.refreshWidgets()
    }
    
    private func calculateFileSize(for document: PDFDocument) -> Int64 {
        let fileURL = getPDFPath(for: document)
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    // Метод для получения накопительной статистики для Quick Stats
    func getCumulativeStatistics() -> (totalDocuments: Int, todayDocuments: Int) {
        let provider = SimpleWidgetDataProvider.shared
        let userDefaults = UserDefaults(suiteName: "group.com.example.myapp.widgets")
        
        let allTimeDocuments = userDefaults?.integer(forKey: "allTimeDocuments") ?? 0
        let todayDocuments = userDefaults?.integer(forKey: "todayDocuments") ?? 0
        
        return (totalDocuments: allTimeDocuments, todayDocuments: todayDocuments)
    }
    
    // Вызывается при создании нового документа
    private func onDocumentCreated(_ document: PDFDocument) {
        // Добавляем новый документ к накопительной статистике
        SimpleWidgetDataProvider.shared.addDocumentToStatistics(pageCount: document.pages)
        
        // Обновляем данные виджетов (включая список последних документов)
        updateWidgetData()
    }
    
    // Вызывается при удалении документа
    private func onDocumentDeleted(_ document: PDFDocument) {
        // При удалении НЕ уменьшаем накопительную статистику (totalDocuments, totalPages)
        // Обновляем только список последних документов и документы за сегодня
        updateWidgetData()
    }
}