import Foundation

// MARK: - Widget Data Provider
// Этот класс обеспечивает обмен данными между основным приложением и виджетами

class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.example.myapp.widgets")
    
    private struct Keys {
        static let recentDocuments = "recentDocuments"
        static let totalDocuments = "totalDocuments"
        static let todayDocuments = "todayDocuments"
        static let totalPages = "totalPages"
        static let lastUpdate = "lastUpdate"
        // Новые ключи для накопительной статистики
        static let allTimeDocuments = "allTimeDocuments"
        static let allTimePages = "allTimePages"
    }
    
    private init() {}
    
    // MARK: - Document Data
    
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
    
    func getRecentDocuments() -> [WidgetDocumentData] {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: Keys.recentDocuments) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([WidgetDocumentData].self, from: data)) ?? []
    }
    
    // MARK: - Statistics
    
    // Метод для добавления нового документа к накопительной статистике
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
    
    // Метод для инициализации накопительной статистики при первом запуске
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
    
    // Обновляем отображаемую статистику на основе накопительных данных
    private func updateDisplayStatistics() {
        guard let userDefaults = userDefaults else { return }
        
        let allTimeDocuments = userDefaults.integer(forKey: Keys.allTimeDocuments)
        let allTimePages = userDefaults.integer(forKey: Keys.allTimePages)
        let todayDocuments = userDefaults.integer(forKey: Keys.todayDocuments)
        
        // Используем накопительную статистику для отображения
        userDefaults.set(allTimeDocuments, forKey: Keys.totalDocuments)
        userDefaults.set(allTimePages, forKey: Keys.totalPages)
    }
    
    private func updateStatistics(totalDocuments: Int, todayDocuments: Int, totalPages: Int) {
        userDefaults?.set(totalDocuments, forKey: Keys.totalDocuments)
        userDefaults?.set(todayDocuments, forKey: Keys.todayDocuments)
        userDefaults?.set(totalPages, forKey: Keys.totalPages)
    }
    
    func getStatistics() -> WidgetStatistics {
        guard let userDefaults = userDefaults else {
            return WidgetStatistics(totalDocuments: 0, todayDocuments: 0, totalPages: 0)
        }
        
        return WidgetStatistics(
            totalDocuments: userDefaults.integer(forKey: Keys.totalDocuments),
            todayDocuments: userDefaults.integer(forKey: Keys.todayDocuments),
            totalPages: userDefaults.integer(forKey: Keys.totalPages)
        )
    }
    
    // MARK: - Data Refresh
    
    func getLastUpdateDate() -> Date? {
        return userDefaults?.object(forKey: Keys.lastUpdate) as? Date
    }
    
    func refreshWidgets() {
        // Уведомляем виджеты об обновлении данных
        #if canImport(WidgetKit)
        import WidgetKit
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

// MARK: - Data Models

struct WidgetDocumentData: Codable {
    let id: String
    let name: String
    let date: Date
    let pageCount: Int
    let fileSize: Int64
    let filePath: String
    
    init(id: String = UUID().uuidString, name: String, date: Date, pageCount: Int, fileSize: Int64 = 0, filePath: String = "") {
        self.id = id
        self.name = name
        self.date = date
        self.pageCount = pageCount
        self.fileSize = fileSize
        self.filePath = filePath
    }
}

struct WidgetStatistics {
    let totalDocuments: Int
    let todayDocuments: Int
    let totalPages: Int
}