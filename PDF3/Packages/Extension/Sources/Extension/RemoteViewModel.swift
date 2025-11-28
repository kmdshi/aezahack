import Network
import Foundation

@MainActor
final class RemoteViewModel: ObservableObject {
    @Published var currentState: ViewState = .main
    @Published var displayAlert = false
    @Published var redirectLink: String?
    @Published var hasParameter = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    init() {
        setupNetworkMonitoring()
        load()
    }
    
    private func load() {
        if !LocalStorage.shared.savedLink.isEmpty {
            redirectLink = LocalStorage.shared.savedLink
            currentState = .service
        } else if LocalStorage.shared.isFirstLaunch {
            Task { await processFirstLaunch() }
        }
    }
    
    private func processFirstLaunch() async {
        if let url = await retrieveRemoteData() {
            redirectLink = url.absoluteString
            currentState = .service
        }
        LocalStorage.shared.isFirstLaunch = false
    }

    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .unsatisfied else { return }
            DispatchQueue.main.async {
                self?.displayAlert = true
                self?.currentState = .main
            }
        }
        monitor.start(queue: queue)
    }
    
    func retrieveRemoteData() async -> URL? {
        do {
            guard let configUrl = URL(string: AppConfig.link) else { 
                handleError()
                return nil 
            }
            
            let (data, _) = try await URLSession.shared.data(from: configUrl)
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let urlString = json["url"],
                  let url = URL(string: urlString) else {
                handleError()
                return nil
            }
            
            return url
        } catch {
            handleError()
            return nil
        }
    }
    
    private func handleError() {
        currentState = .main
    }
    
    deinit {
        monitor.cancel()
    }
}
