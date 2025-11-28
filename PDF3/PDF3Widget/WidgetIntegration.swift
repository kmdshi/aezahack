import Foundation
import SwiftUI

// MARK: - Widget Integration Helper
// Добавьте этот код в основное приложение для интеграции с виджетами

extension AppState {
    
    // Метод для обновления данных виджетов при изменении документов
    func updateWidgetData() {
        let widgetDocs = documents.map { doc in
            WidgetDocumentData(
                name: doc.name,
                date: doc.createdAt,
                pageCount: doc.pageCount,
                fileSize: calculateFileSize(for: doc),
                filePath: doc.filePath
            )
        }
        
        // Сортируем по дате создания (новые сначала)
        let sortedDocs = widgetDocs.sorted { $0.date > $1.date }
        
        // Инициализируем накопительную статистику при первом запуске
        WidgetDataProvider.shared.initializeStatisticsIfNeeded(currentDocuments: widgetDocs)
        
        // Обновляем список последних документов и документы за сегодня
        WidgetDataProvider.shared.updateRecentDocuments(Array(sortedDocs.prefix(10)))
        
        // Обновляем виджеты
        WidgetDataProvider.shared.refreshWidgets()
    }
    
    private func calculateFileSize(for document: PDFDocument) -> Int64 {
        guard let url = URL(string: document.filePath) else { return 0 }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
}

// MARK: - Widget URL Handler Extension
extension ContentView {
    
    // Добавьте этот метод в ContentView для обработки URL от виджетов
    func handleWidgetAction(_ action: WidgetAction) {
        switch action {
        case .openDocuments:
            // Переход к экрану с документами
            print("📱 Opening documents screen")
            
        case .openDocument(let name):
            // Открытие конкретного документа
            if let document = appState.documents.first(where: { $0.name == name }) {
                print("📱 Opening document: \(name)")
                // Здесь должна быть логика открытия документа
            }
            
        case .scan:
            // Запуск сканера
            print("📱 Starting scanner")
            
        case .createPDF:
            // Создание нового PDF
            print("📱 Creating new PDF")
            
        case .sign:
            // Режим подписи
            print("📱 Entering signature mode")
            
        case .share:
            // Поделиться
            print("📱 Opening share menu")
            
        case .statistics:
            // Статистика
            print("📱 Opening statistics")
        }
    }
}

// MARK: - Widget Actions Enum
enum WidgetAction {
    case openDocuments
    case openDocument(String)
    case scan
    case createPDF
    case sign
    case share
    case statistics
    
    static func from(url: URL) -> WidgetAction? {
        guard url.scheme == "pdf3" else { return nil }
        
        switch url.host {
        case "open":
            if url.pathComponents.count > 1 {
                let documentName = String(url.pathComponents[1].removingPercentEncoding ?? url.pathComponents[1])
                return .openDocument(documentName)
            } else {
                return .openDocuments
            }
        case "scan": return .scan
        case "create": return .createPDF
        case "sign": return .sign
        case "share": return .share
        case "statistics": return .statistics
        default: return nil
        }
    }
}

// MARK: - Document Lifecycle Hooks
// Добавьте эти вызовы в соответствующие места вашего приложения

extension AppState {
    
    // Вызывайте при создании нового документа
    func onDocumentCreated(_ document: PDFDocument) {
        // Ваша существующая логика...
        
        // Добавляем новый документ к накопительной статистике
        WidgetDataProvider.shared.addDocumentToStatistics(pageCount: document.pageCount)
        
        // Обновляем данные виджетов (включая список последних документов)
        updateWidgetData()
    }
    
    // Вызывайте при изменении документа
    func onDocumentModified(_ document: PDFDocument) {
        // Ваша существующая логика...
        
        // Обновляем данные виджетов
        updateWidgetData()
    }
    
    // Вызывайте при удалении документа
    func onDocumentDeleted(_ document: PDFDocument) {
        // Ваша существующая логика...
        
        // При удалении НЕ уменьшаем накопительную статистику (totalDocuments, totalPages)
        // Обновляем только список последних документов и документы за сегодня
        updateWidgetData()
    }
    
    // Вызывайте при загрузке приложения
    func onAppLaunched() {
        // Ваша существующая логика...
        
        // Обновляем данные виджетов
        updateWidgetData()
    }
}

// MARK: - Background Refresh
// Для обновления виджетов в фоне

class WidgetUpdateManager {
    static let shared = WidgetUpdateManager()
    
    private init() {}
    
    // Планируем обновление виджетов
    func scheduleWidgetRefresh() {
        #if canImport(WidgetKit)
        import WidgetKit
        
        // Обновляем через 5 минут
        let futureDate = Date().addingTimeInterval(5 * 60)
        WidgetCenter.shared.reloadTimelines(ofKind: "PDF3Widget")
        WidgetCenter.shared.reloadTimelines(ofKind: "QuickActionsWidget") 
        WidgetCenter.shared.reloadTimelines(ofKind: "StatisticsWidget")
        #endif
    }
    
    // Принудительное обновление всех виджетов
    func forceRefreshAllWidgets() {
        #if canImport(WidgetKit)
        import WidgetKit
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

// MARK: - Пример использования в SceneDelegate или AppDelegate

/*
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let action = WidgetAction.from(url: url) else { return }
        
        // Обрабатываем действие виджета
        if let contentView = window?.rootViewController as? ContentView {
            contentView.handleWidgetAction(action)
        }
    }
}
*/