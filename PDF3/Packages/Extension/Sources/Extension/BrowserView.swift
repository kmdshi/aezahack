import SwiftUI
@preconcurrency import WebKit

struct BrowserView: UIViewRepresentable {
    let url: String
    let viewModel: RemoteViewModel
    private let customUserAgent = generateUserAgent()
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(
            frame: .zero,
            configuration: createConfiguration()
        )
        configureWebView(webView, coordinator: context.coordinator)
        loadInitialUrl(webView)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    private func createConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        return configuration
    }
    
    private func configureWebView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.navigationDelegate = coordinator
        webView.customUserAgent = customUserAgent
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func loadInitialUrl(_ webView: WKWebView) {
        guard let linkURL = URL(string: url) else { return }
        webView.load(URLRequest(url: linkURL))
    }
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BrowserView
        
        init(_ parent: BrowserView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            handleNavigation(navigationAction)
            navigationAction.request.url.map(processUrl)
            decisionHandler(shouldAllowNavigation(navigationAction))
        }
        private func handleNavigation(_ navigationAction: WKNavigationAction) {
            if let navUrl = navigationAction.request.url {
                if navUrl.query?.contains("showAgreebutton") == true {
                    parent.viewModel.hasParameter = true
                } else {
                    saveLinkOrClear(navUrl)
                }
            }
        }
        
        private func saveLinkOrClear(_ navUrl: URL) {
            if !parent.viewModel.hasParameter {
                LocalStorage.shared.savedLink = parent.url
            } else {
                LocalStorage.shared.savedLink = ""
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            AppRatingManager.shared.checkAndRequestReview()
        }
        
        private func processUrl(_ url: URL) {
            updateStoredLink()
        }
        
        private func updateStoredLink() {
            LocalStorage.shared.savedLink = parent.viewModel.hasParameter ? "" : parent.url
        }
        
        private func shouldAllowNavigation(_ navigationAction: WKNavigationAction) -> WKNavigationActionPolicy {
            guard let url = navigationAction.request.url, let scheme = url.scheme else {
                return .allow
            }
            
            let externalSchemes = ["tel", "mailto", "tg", "phonepe", "paytmmp"]
            if externalSchemes.contains(scheme) {
                UIApplication.shared.open(url)
                return .cancel
            }
            return .allow
        }
    }
}

private func generateUserAgent() -> String {
    let device = UIDevice.current
    let osVersion = device.systemVersion.replacingOccurrences(of: ".", with: "_")
    
    return """
    Mozilla/5.0 (\(device.model); CPU \(device.model) OS \(osVersion) like Mac OS X) \
    AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(device.systemVersion) Mobile/15E148 Safari/604.1
    """
}
