import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            if appState.isOnboardingComplete {
                MainView(appState: appState)
            } else {
                OnboardingView {
                    appState.isOnboardingComplete = true
                }
            }
        }
    }
}
