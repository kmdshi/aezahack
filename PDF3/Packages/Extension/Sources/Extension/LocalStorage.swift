import SwiftUI

public struct LocalStorage {
    public static let shared = LocalStorage()
    
    @AppStorage("LYNK") public var savedLink = ""
    @AppStorage("FIRSTLAUNCH") public var isFirstLaunch = true
}

enum ViewState: Equatable {
    case main, service
}

