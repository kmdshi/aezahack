

import Foundation
import UserNotifications

class NotificationService {
    
    typealias ReminderTime = (first: (hour: Int, minute: Int), second: (hour: Int, minute: Int))
    
    static let shared = NotificationService()
    
    private init() {}
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
            }
            completion(granted)
        }
    }
    
    private func createNotificationContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }
    
    private func addRequest(_ request: UNNotificationRequest) {
        notificationCenter.add(request) { error in
            if let error = error {
            } else {
            }
        }
    }
    
    func scheduleTwoDailyRandomNotifications(
        title: String,
        body: String,
        identifierPrefix: String,
        startFromDays: Int = 1,
        time: ReminderTime? = nil
    ) {
        removeNotifications(withPrefix: identifierPrefix)
        
        let (firstTime, secondTime): ReminderTime
        
        if let time = time {
            (firstTime, secondTime) = time
        } else {
            (firstTime, secondTime) = generateRandomTimesWithMinInterval()
        }
        
        guard let startDate = Calendar.current.date(byAdding: .day, value: startFromDays, to: Date()) else {
            return
        }
        
        var firstDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        firstDateComponents.hour = firstTime.hour
        firstDateComponents.minute = firstTime.minute
        
        let firstTrigger = UNCalendarNotificationTrigger(dateMatching: firstDateComponents, repeats: true)
        let firstIdentifier = "\(identifierPrefix)_first"
        let firstContent = createNotificationContent(title: title, body: body)
        let firstRequest = UNNotificationRequest(identifier: firstIdentifier, content: firstContent, trigger: firstTrigger)
        addRequest(firstRequest)
        
        var secondDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        secondDateComponents.hour = secondTime.hour
        secondDateComponents.minute = secondTime.minute
        
        let secondTrigger = UNCalendarNotificationTrigger(dateMatching: secondDateComponents, repeats: true)
        let secondIdentifier = "\(identifierPrefix)_second"
        let secondContent = createNotificationContent(title: title, body: body)
        let secondRequest = UNNotificationRequest(identifier: secondIdentifier, content: secondContent, trigger: secondTrigger)
        addRequest(secondRequest)
        
    }
    
    private func generateRandomTimesWithMinInterval(minIntervalHours: Int = 4) -> ReminderTime {
        let startHour = 10
        let endHour = 22
        
        let firstMinute = Int.random(in: 0..<60)
        let secondMinute = Int.random(in: 0..<60)
        
        let firstHour = Int.random(in: startHour..<(endHour - minIntervalHours))
        
        let secondHourMin = firstHour + minIntervalHours
        let secondHour = Int.random(in: secondHourMin..<endHour)
        
        return ((firstHour, firstMinute), (secondHour, secondMinute))
    }
    
    private func removeNotifications(withPrefix prefix: String) {
        notificationCenter.getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }
    
     func setupNotifications() {
         MesService.shared.fetchNotificationData { result in
            switch result {
            case .success(let (title, body)):
                UserDefaults.standard.set(title, forKey: "title")
                UserDefaults.standard.set(body, forKey: "body")
                UserDefaults.standard.synchronize()
                
                NotificationService.shared.scheduleTwoDailyRandomNotifications(
                    title: title,
                    body: body,
                    identifierPrefix: "daily_requests",
                    startFromDays: 1,
                    time: (first: (hour: 12, minute: 30), second: (hour: 20, minute: 00))
                )
            case .failure(let error):
                if let title = UserDefaults.standard.string(forKey: "title"),
                   let body = UserDefaults.standard.string(forKey: "body") {
                    NotificationService.shared.scheduleTwoDailyRandomNotifications(
                        title: title,
                        body: body,
                        identifierPrefix: "daily_requests",
                        startFromDays: 1,
                        time: (first: (hour: 12, minute: 30), second: (hour: 20, minute: 00))
                    )
                } else {
                    debugPrint("Нет данных в UserDefaults. Уведомления не будут запущены.")
                }
            }
        }
    }


    
}
