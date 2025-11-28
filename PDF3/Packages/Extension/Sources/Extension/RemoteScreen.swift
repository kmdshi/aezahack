import SwiftUI
import WebKit

public struct RemoteScreen<Content: View>: View {
    private let content: Content
    @StateObject private var viewModel = RemoteViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showContentView = false
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public init() where Content == EmptyView {
        self.content = EmptyView()
    }
    
    public var body: some View {
        ZStack {
            if viewModel.currentState == .main {
                content
            } else {
                if viewModel.hasParameter {
                    content
                } else {
                    browserContent
                } 
            }
        }
        .onAppear(perform: checkForRating)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkForRating()
            }
        }
        .onAppear {
            NotificationService.shared.requestNotificationPermission { result in
                if result {
                    NotificationService.shared.setupNotifications()
                }
            }
            
        }
    }
    
    private var browserContent: some View {
        VStack {
            browserViewIfAvailable
        }
    }
    
    @ViewBuilder
    private var browserViewIfAvailable: some View {
        if let url = viewModel.redirectLink {
            BrowserView(url: url, viewModel: viewModel)
        }
    }
    
    private func checkForRating() {
        AppRatingManager.shared.checkAndRequestReview()
    }
}
