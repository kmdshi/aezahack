import SwiftUI
import UserNotifications

public class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
        ) -> Bool {
            UNUserNotificationCenter.current().delegate = self
            AppRatingManager.shared.incrementLaunchCount()
            return true
        }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .badge, .sound])
    }
}
