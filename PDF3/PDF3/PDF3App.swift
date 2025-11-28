import SwiftUI

@main
struct PDF3App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleWidgetURL(url)
                }
        }
    }
    
    private func handleWidgetURL(_ url: URL) {
        guard url.scheme == "pdf3" else { return }
        
        switch url.host {
        case "open":
            // Открыть список документов или конкретный документ
            if url.pathComponents.count > 1 {
                let documentName = url.pathComponents[1]
                print("🔗 Opening document: \(documentName)")
                // Здесь можно добавить навигацию к конкретному документу
            } else {
                print("🔗 Opening documents list")
                // Навигация к списку документов
            }
            
        case "scan":
            print("🔗 Opening scanner")
            // Открыть сканер документов
            
        case "create":
            print("🔗 Opening document creator")
            // Открыть создание нового PDF
            
        case "sign":
            print("🔗 Opening signature mode")
            // Открыть режим подписания
            
        case "share":
            print("🔗 Opening share menu")
            // Открыть меню поделиться
            
        case "statistics":
            print("🔗 Opening statistics")
            // Открыть статистику
            
        default:
            print("🔗 Unknown URL: \(url)")
        }
    }
}