import StoreKit
import SwiftUI

public final class AppRatingManager: ObservableObject {
    public static let shared = AppRatingManager()
    @AppStorage("LAUNCHCOUNT") private var appLaunchCount = 0
    @AppStorage("RATINGREQUEST") private var lastRatingRequest = Date.distantPast.timeIntervalSince1970
    @AppStorage("RATINGREQUESTCOUNT") private var ratingRequestCount = 0
    
    private let minLaunchesBeforeRating = 0
    private let minDaysBetweenRequests = 1.0
    private let maxRatingRequests = 5
    private var hasShowedRating = false
    
    private init() {}
    
    public func incrementLaunchCount() {
        appLaunchCount += 1
    }
    
    public func shouldRequestRating() -> Bool {
        let daysSinceLastRequest = Date().timeIntervalSince1970 - lastRatingRequest
        return appLaunchCount >= minLaunchesBeforeRating &&
        (daysSinceLastRequest / 86400) >= minDaysBetweenRequests &&
        ratingRequestCount < maxRatingRequests &&
        !hasShowedRating
    }

    public func requestRating() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive
        }) as? UIWindowScene else { return }
        
        SKStoreReviewController.requestReview(in: scene)
        lastRatingRequest = Date().timeIntervalSince1970
        ratingRequestCount += 1
    }

    public func checkAndRequestReview() {
        guard shouldRequestRating() else { return }
        hasShowedRating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.requestRating()
        }
    }
    
}
