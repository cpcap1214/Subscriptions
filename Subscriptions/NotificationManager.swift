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
    private let localizationManager = LocalizationManager.shared
    
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
        content.title = localizationManager.localizedString(for: .paymentReminderTitle)
        let formattedCurrency = formatCurrency(subscription.cost, currency: subscription.currency)
        content.body = String(format: localizationManager.localizedString(for: .paymentReminderBody), subscription.name, formattedCurrency)
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
    
    func getDetailedNotificationStatus() async -> String {
        let settings = await notificationCenter.notificationSettings()
        
        var statusInfo = ["📱 詳細通知狀態報告"]
        statusInfo.append("授權狀態: \(settings.authorizationStatus.description)")
        statusInfo.append("提醒樣式: \(settings.alertSetting.description)")
        statusInfo.append("聲音: \(settings.soundSetting.description)")
        statusInfo.append("標記: \(settings.badgeSetting.description)")
        statusInfo.append("鎖定螢幕: \(settings.lockScreenSetting.description)")
        statusInfo.append("通知中心: \(settings.notificationCenterSetting.description)")
        statusInfo.append("橫幅: \(settings.alertStyle.description)")
        
        if #available(iOS 15.0, *) {
            statusInfo.append("定時摘要: \(settings.scheduledDeliverySetting.description)")
        }
        
        return statusInfo.joined(separator: "\n")
    }
    
    func printDetailedNotificationStatus() {
        Task {
            let statusInfo = await getDetailedNotificationStatus()
            print(statusInfo)
        }
    }
    
    func scheduleTestNotification(for subscription: Subscription, delaySeconds: Double = 5.0) {
        // Check notification permission first
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let authorizationStatus = settings.authorizationStatus
                
                print("🔔 測試通知權限狀態: \(authorizationStatus.rawValue)")
                
                switch authorizationStatus {
                case .notDetermined:
                    print("⚠️ 通知權限未決定，請先到設定頁面開啟通知權限")
                    // Try to request permission automatically
                    Task {
                        let granted = await self.requestNotificationPermission()
                        if granted {
                            self.scheduleTestNotificationInternal(for: subscription, delaySeconds: delaySeconds)
                        }
                    }
                    return
                case .denied:
                    print("❌ 通知權限被拒絕，請到 iOS 設定 -> \(Bundle.main.displayName ?? "Subscriptions") -> 通知 中開啟")
                    return
                case .authorized, .provisional, .ephemeral:
                    print("✅ 通知權限已授權，準備發送測試通知")
                    self.scheduleTestNotificationInternal(for: subscription, delaySeconds: delaySeconds)
                @unknown default:
                    print("❓ 未知的通知權限狀態")
                    return
                }
            }
        }
    }
    
    private func scheduleTestNotificationInternal(for subscription: Subscription, delaySeconds: Double) {
        // Create test notification content
        let content = UNMutableNotificationContent()
        content.title = localizationManager.localizedString(for: .testNotificationTitle)
        content.body = String(format: localizationManager.localizedString(for: .testNotificationBody), subscription.name)
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
                print("❌ 測試通知發送失敗: \(error.localizedDescription)")
            } else {
                print("✅ 測試通知已安排發送，\(delaySeconds) 秒後將收到通知 (\(subscription.name))")
                print("💡 提示：如果應用程式在前台，通知可能不會彈出。請將應用程式切換到背景或鎖定螢幕來測試。")
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
            title: localizationManager.localizedString(for: .openAppAction),
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: localizationManager.localizedString(for: .remindLaterAction),
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

// MARK: - UNNotificationSettings Extensions

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "未決定"
        case .denied: return "已拒絕"
        case .authorized: return "已授權"
        case .provisional: return "臨時授權"
        case .ephemeral: return "臨時應用授權"
        @unknown default: return "未知狀態"
        }
    }
}

extension UNNotificationSetting {
    var description: String {
        switch self {
        case .enabled: return "已啟用"
        case .disabled: return "已停用"
        case .notSupported: return "不支援"
        @unknown default: return "未知"
        }
    }
}

extension UNAlertStyle {
    var description: String {
        switch self {
        case .none: return "無"
        case .banner: return "橫幅"
        case .alert: return "警示"
        @unknown default: return "未知"
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}