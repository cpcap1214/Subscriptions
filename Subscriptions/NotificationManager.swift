//
//  NotificationManager.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationEnabled = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    private let notificationEnabledKey = "isNotificationEnabled"
    
    private init() {
        loadNotificationSettings()
        checkNotificationStatus()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isNotificationEnabled = granted
                saveNotificationSettings()
            }
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    func checkNotificationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = settings.authorizationStatus == .authorized
                self.saveNotificationSettings()
            }
        }
    }
    
    // MARK: - Settings Persistence
    
    private func loadNotificationSettings() {
        isNotificationEnabled = userDefaults.bool(forKey: notificationEnabledKey)
    }
    
    private func saveNotificationSettings() {
        userDefaults.set(isNotificationEnabled, forKey: notificationEnabledKey)
    }
    
    // MARK: - Subscription Notifications
    
    func scheduleNotification(for subscription: Subscription) {
        guard isNotificationEnabled else { return }
        
        // Calculate notification date (2 days before payment)
        let notificationDate = Calendar.current.date(byAdding: .day, value: -2, to: subscription.nextPaymentDate)
        
        guard let notificationDate = notificationDate, notificationDate > Date() else {
            // If notification date is in the past, don't schedule
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "即將扣款提醒"
        content.body = "\(subscription.name) 將在 2 天後扣款 \(formatCurrency(subscription.cost, currency: subscription.currency))"
        content.sound = .default
        content.badge = 1
        
        // Add category for actions
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        
        // Create trigger
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let identifier = "subscription_\(subscription.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification for \(subscription.name): \(error)")
            } else {
                print("Successfully scheduled notification for \(subscription.name) at \(notificationDate)")
            }
        }
    }
    
    func cancelNotification(for subscription: Subscription) {
        let identifier = "subscription_\(subscription.id.uuidString)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled notification for \(subscription.name)")
    }
    
    func rescheduleAllNotifications(for subscriptions: [Subscription]) {
        // Cancel all existing notifications
        cancelAllNotifications()
        
        // Schedule new notifications
        for subscription in subscriptions where subscription.isActive {
            scheduleNotification(for: subscription)
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("Cancelled all pending notifications")
    }
    
    // MARK: - Debugging Helpers
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    func printPendingNotifications() {
        Task {
            let requests = await getPendingNotifications()
            print("Pending notifications: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let nextTriggerDate = trigger.nextTriggerDate() {
                    print("- \(request.identifier): \(request.content.body) at \(nextTriggerDate)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    let nextTriggerDate = Date().addingTimeInterval(trigger.timeInterval)
                    print("- \(request.identifier): \(request.content.body) in \(trigger.timeInterval)s at \(nextTriggerDate)")
                }
            }
        }
    }
    
    func scheduleTestNotification(for subscription: Subscription, delaySeconds: Double = 5.0) {
        // Create test notification content
        let content = UNMutableNotificationContent()
        content.title = "🛠 測試通知"
        content.body = "這是 \(subscription.name) 的測試通知，實際會在扣款前 2 天發送。"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        
        // Create delayed trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
        
        // Create request
        let identifier = "test_notification_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send test notification: \(error)")
            } else {
                print("Test notification scheduled for \(subscription.name) in \(delaySeconds) seconds")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            let currencyEnum = Currency(rawValue: currency) ?? .usd
            return "\(currencyEnum.symbol)\(String(format: "%.2f", amount))"
        }
    }
}

// MARK: - Notification Categories

extension NotificationManager {
    func setupNotificationCategories() {
        // Create actions
        let openAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "開啟應用程式",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "稍後提醒",
            options: []
        )
        
        // Create category
        let category = UNNotificationCategory(
            identifier: "SUBSCRIPTION_REMINDER",
            actions: [openAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register category
        notificationCenter.setNotificationCategories([category])
    }
}