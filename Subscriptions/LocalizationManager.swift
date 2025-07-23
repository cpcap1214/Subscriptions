//
//  LocalizationManager.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            saveLanguagePreference()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "AppLanguage"
    
    private init() {
        // Set default language based on system language
        self.currentLanguage = Self.getSystemLanguage()
        print("🌐 系統檢測語言: \(self.currentLanguage.displayName)")
        
        loadLanguagePreference()
        print("🌐 最終使用語言: \(self.currentLanguage.displayName)")
    }
    
    private func loadLanguagePreference() {
        // Only override system language if user has explicitly set a preference
        if let languageString = userDefaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: languageString) {
            print("🌐 載入用戶偏好語言: \(language.displayName)")
            currentLanguage = language
        } else {
            print("🌐 無用戶偏好設定，保持系統檢測語言")
        }
        // If no user preference exists, keep the system-detected language
    }
    
    private func saveLanguagePreference() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
    }
    
    private static func getSystemLanguage() -> AppLanguage {
        // Get the preferred language from system settings
        let preferredLanguages = Locale.preferredLanguages
        print("🌐 系統偏好語言: \(preferredLanguages)")
        
        // Check if any preferred language matches our supported languages
        for languageCode in preferredLanguages {
            let baseLanguageCode = String(languageCode.prefix(2)) // Get base language code (e.g., "zh" from "zh-Hant-TW")
            
            switch baseLanguageCode {
            case "zh":
                // Check if it's Traditional Chinese (Taiwan, Hong Kong, etc.)
                if languageCode.contains("Hant") || 
                   languageCode.contains("TW") || 
                   languageCode.contains("HK") || 
                   languageCode.contains("MO") {
                    print("🌐 檢測到繁體中文: \(languageCode)")
                    return .traditionalChinese
                }
                // For Simplified Chinese, we'll default to Traditional Chinese since we only support Traditional
                print("🌐 檢測到簡體中文，使用繁體中文: \(languageCode)")
                return .traditionalChinese
            case "en":
                print("🌐 檢測到英文: \(languageCode)")
                return .english
            default:
                continue
            }
        }
        
        // If no matching language found, check system region
        let currentLocale = Locale.current
        if let regionCode = currentLocale.regionCode {
            switch regionCode {
            case "TW", "HK", "MO": // Taiwan, Hong Kong, Macau
                return .traditionalChinese
            case "CN", "SG": // China, Singapore - but we only support Traditional Chinese
                return .traditionalChinese
            default:
                break
            }
        }
        
        // Default to English if no specific preference is detected
        print("🌐 未檢測到支援的語言，預設使用英文")
        return .english
    }
    
    func localizedString(for key: LocalizationKey) -> String {
        return key.localized(for: currentLanguage)
    }
    
    // Reset language preference to system default
    func resetToSystemLanguage() {
        userDefaults.removeObject(forKey: languageKey)
        currentLanguage = Self.getSystemLanguage()
        print("🌐 重設為系統語言: \(currentLanguage.displayName)")
    }
}

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case traditionalChinese = "zh-Hant"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "繁體中文"
        }
    }
    
    var nativeName: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "繁體中文"
        }
    }
}

enum LocalizationKey {
    // App Title
    case appTitle
    case appSubtitle
    
    // Dashboard
    case dashboard
    case total
    case thisMonth
    case nextPayment
    case viewAllSubscriptions
    case addSubscription
    case noUpcomingPayments
    
    // Stats
    case stats
    case monthly
    case yearly
    case byCategory
    case upcomingPayments
    case upcomingPaymentsDescription
    case noUpcomingPaymentsStats
    
    // Settings
    case settings
    case customizeExperience
    case preferences
    case dataOverview
    case about
    case preferredCurrency
    case preferredCurrencyDescription
    case language
    case languageDescription
    case totalSubscriptions
    case totalSubscriptionsDescription
    case monthlyTotal
    case monthlyTotalDescription
    case yearlyTotal
    case yearlyTotalDescription
    case appVersion
    case madeWithCare
    case madeWithCareDescription
    
    // Add Subscription
    case addNewSubscription
    case trackYourServices
    case serviceName
    case serviceNamePlaceholder
    case amount
    case category
    case firstPaymentDate
    case billingCycle
    case cancel
    case save
    case errorTitle
    case enterServiceName
    case enterValidAmount
    
    // All Subscriptions
    case allSubscriptions
    case activeServices
    case noSubscriptionsYet
    case addFirstSubscription
    case close
    case nextPaymentShort
    case edit
    case delete
    case deleteConfirmTitle
    case deleteConfirmMessage
    case per
    
    // Theme
    case appearance
    case appearanceDescription
    case lightTheme
    case darkTheme
    case systemTheme
    case paymentReminders
    case showOnboardingAgain
    case autoCalculateNextPayment
    case autoCalculateNextPaymentDescription
    case selectService
    case searchOrCustomize
    case done
    case ok
    case startDate
    case billingCycleLabel
    case description
    case monthlyEquivalent
    case yearlyEquivalent
    case editSubscription
    case updateServiceInfo
    case nextPaymentDate
    
    // Common
    case today
    case tomorrow
    case inDays
    case daysSuffix
    case activeServicesCount
    
    // Stats page specific
    case categoryAnalysisDescription
    case percentageOfTotal
    
    // Category Detail
    case back
    case noCategorySubscriptions
    case noCategorySubscriptionsDescription
    
    // Onboarding
    case skip
    case next
    case getStarted
    case enableNotifications
    case trackSubscriptionsTitle
    case trackSubscriptionsDescription
    case analyzeSpendingTitle
    case analyzeSpendingDescription
    case smartRemindersTitle
    case smartRemindersDescription
    case minimalExperienceTitle
    case minimalExperienceDescription
    
    // Notifications
    case paymentReminderTitle
    case paymentReminderBody
    case testNotificationTitle
    case testNotificationBody
    case openAppAction
    case remindLaterAction
    
    func localized(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return englishTranslation
        case .traditionalChinese:
            return chineseTranslation
        }
    }
    
    private var englishTranslation: String {
        switch self {
        case .appTitle: return "Subscriptions"
        case .appSubtitle: return "Minimalist subscription tracking"
        case .dashboard: return "Dashboard"
        case .total: return "Total"
        case .thisMonth: return "this month"
        case .nextPayment: return "NEXT PAYMENT"
        case .viewAllSubscriptions: return "View All Subscriptions"
        case .addSubscription: return "Add Subscription"
        case .noUpcomingPayments: return "No upcoming payments"
        case .stats: return "Stats"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .byCategory: return "By Category"
        case .upcomingPayments: return "Upcoming Payments (30 days)"
        case .upcomingPaymentsDescription: return "Next 30 days"
        case .noUpcomingPaymentsStats: return "No upcoming payments in the next 30 days"
        case .settings: return "Settings"
        case .customizeExperience: return "Customize your experience"
        case .preferences: return "Preferences"
        case .dataOverview: return "Data Overview"
        case .about: return "About"
        case .preferredCurrency: return "Preferred Currency"
        case .preferredCurrencyDescription: return "Default currency for new subscriptions"
        case .language: return "Language"
        case .languageDescription: return "Choose your preferred language"
        case .totalSubscriptions: return "Total Subscriptions"
        case .totalSubscriptionsDescription: return "active services"
        case .monthlyTotal: return "Monthly Total"
        case .monthlyTotalDescription: return "Across all subscriptions"
        case .yearlyTotal: return "Yearly Total"
        case .yearlyTotalDescription: return "Annual spending estimate"
        case .appVersion: return "LifeOS: Subscriptions"
        case .madeWithCare: return "Made with Care"
        case .madeWithCareDescription: return "Built for simplicity and efficiency"
        case .addNewSubscription: return "Add New Subscription"
        case .trackYourServices: return "Track your monthly services"
        case .serviceName: return "Service Name"
        case .serviceNamePlaceholder: return "e.g., Netflix, Spotify, Adobe..."
        case .amount: return "Amount"
        case .category: return "Category"
        case .firstPaymentDate: return "First Payment Date"
        case .billingCycle: return "Billing Cycle"
        case .cancel: return "Cancel"
        case .save: return "Save"
        case .errorTitle: return "Error"
        case .enterServiceName: return "Please enter a service name"
        case .enterValidAmount: return "Please enter a valid amount"
        case .allSubscriptions: return "All Subscriptions"
        case .activeServices: return "active services"
        case .noSubscriptionsYet: return "No Subscriptions Yet"
        case .addFirstSubscription: return "Add your first subscription to get started"
        case .close: return "Close"
        case .nextPaymentShort: return "Next"
        case .edit: return "Edit"
        case .delete: return "Delete"
        case .deleteConfirmTitle: return "Delete Subscription"
        case .deleteConfirmMessage: return "Are you sure you want to delete %@? This action cannot be undone."
        case .per: return "per"
        case .appearance: return "Appearance"
        case .appearanceDescription: return "Choose your preferred theme"
        case .lightTheme: return "Light"
        case .darkTheme: return "Dark"
        case .systemTheme: return "System"
        case .paymentReminders: return "Payment Reminders"
        case .showOnboardingAgain: return "Show Onboarding Again"
        case .autoCalculateNextPayment: return "Auto-calculate next payment"
        case .autoCalculateNextPaymentDescription: return ""
        case .selectService: return "Select Service"
        case .searchOrCustomize: return "Search common services or customize..."
        case .done: return "Done"
        case .ok: return "OK"
        case .startDate: return "Start Date"
        case .billingCycleLabel: return "Billing Cycle"
        case .description: return "Description"
        case .monthlyEquivalent: return "Monthly Equivalent"
        case .yearlyEquivalent: return "Yearly Equivalent"
        case .editSubscription: return "Edit Subscription"
        case .updateServiceInfo: return "Update your service information"
        case .nextPaymentDate: return "Next Payment Date"
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        case .inDays: return "in %d days"
        case .daysSuffix: return "d"
        case .activeServicesCount: return "%d active services"
        case .categoryAnalysisDescription: return "Analyze your monthly spending distribution"
        case .percentageOfTotal: return "% of total"
        case .back: return "Back"
        case .noCategorySubscriptions: return "No Subscriptions in this Category"
        case .noCategorySubscriptionsDescription: return "Add a subscription to this category to see it here"
        case .skip: return "Skip"
        case .next: return "Next"
        case .getStarted: return "Get Started"
        case .enableNotifications: return "Enable Notifications"
        case .trackSubscriptionsTitle: return "Track Your Subscriptions"
        case .trackSubscriptionsDescription: return "Easily manage all your monthly and annual services, never forget to cancel unwanted subscriptions."
        case .analyzeSpendingTitle: return "Analyze Spending Trends"
        case .analyzeSpendingDescription: return "Clearly understand your monthly subscription spending distribution to help you make smarter financial decisions."
        case .smartRemindersTitle: return "Smart Payment Reminders"
        case .smartRemindersDescription: return "Automatic notifications 2 days before charges, avoid unexpected billing and keep your financial planning stable."
        case .minimalExperienceTitle: return "Minimal Experience"
        case .minimalExperienceDescription: return "Focus on truly important features, clean interface makes subscription management easy and enjoyable."
        case .paymentReminderTitle: return "Payment Reminder"
        case .paymentReminderBody: return "%@ will be charged %@ in 2 days"
        case .testNotificationTitle: return "🛠 Test Notification"
        case .testNotificationBody: return "This is a test notification for %@, actual notifications will be sent 2 days before charges."
        case .openAppAction: return "Open App"
        case .remindLaterAction: return "Remind Later"
        }
    }
    
    private var chineseTranslation: String {
        switch self {
        case .appTitle: return "訂閱管理"
        case .appSubtitle: return "極簡訂閱追蹤"
        case .dashboard: return "主頁"
        case .total: return "總計"
        case .thisMonth: return "本月"
        case .nextPayment: return "下次付款"
        case .viewAllSubscriptions: return "查看所有訂閱"
        case .addSubscription: return "新增訂閱"
        case .noUpcomingPayments: return "無即將到期的付款"
        case .stats: return "統計"
        case .monthly: return "月度"
        case .yearly: return "年度"
        case .byCategory: return "依分類"
        case .upcomingPayments: return "即將到期付款（30天內）"
        case .upcomingPaymentsDescription: return "未來30天"
        case .noUpcomingPaymentsStats: return "未來30天內無即將到期的付款"
        case .settings: return "設定"
        case .customizeExperience: return "自訂您的使用體驗"
        case .preferences: return "偏好設定"
        case .dataOverview: return "資料概覽"
        case .about: return "關於"
        case .preferredCurrency: return "偏好貨幣"
        case .preferredCurrencyDescription: return "新訂閱的預設貨幣"
        case .language: return "語言"
        case .languageDescription: return "選擇您偏好的語言"
        case .totalSubscriptions: return "訂閱總數"
        case .totalSubscriptionsDescription: return "個訂閱服務"
        case .monthlyTotal: return "月度總計"
        case .monthlyTotalDescription: return "所有訂閱總和"
        case .yearlyTotal: return "年度總計"
        case .yearlyTotalDescription: return "年度支出預估"
        case .appVersion: return "LifeOS: 訂閱管理"
        case .madeWithCare: return "用心製作"
        case .madeWithCareDescription: return "為簡潔高效而生"
        case .addNewSubscription: return "新增訂閱"
        case .trackYourServices: return "追蹤您的訂閱服務"
        case .serviceName: return "服務名稱"
        case .serviceNamePlaceholder: return "例如：Netflix、Spotify、Adobe..."
        case .amount: return "金額"
        case .category: return "分類"
        case .firstPaymentDate: return "首次付款日期"
        case .billingCycle: return "計費週期"
        case .cancel: return "取消"
        case .save: return "儲存"
        case .errorTitle: return "錯誤"
        case .enterServiceName: return "請輸入服務名稱"
        case .enterValidAmount: return "請輸入有效金額"
        case .allSubscriptions: return "所有訂閱"
        case .activeServices: return "個訂閱服務"
        case .noSubscriptionsYet: return "尚無訂閱"
        case .addFirstSubscription: return "新增您的第一個訂閱開始使用"
        case .close: return "關閉"
        case .nextPaymentShort: return "下次"
        case .edit: return "編輯"
        case .delete: return "刪除"
        case .deleteConfirmTitle: return "刪除訂閱"
        case .deleteConfirmMessage: return "確定要刪除「%@」嗎？"
        case .per: return "每"
        case .appearance: return "外觀"
        case .appearanceDescription: return "選擇您偏好的主題"
        case .lightTheme: return "淺色"
        case .darkTheme: return "深色"
        case .systemTheme: return "系統設定"
        case .paymentReminders: return "付款提醒"
        case .showOnboardingAgain: return "重新觀看導覽"
        case .autoCalculateNextPayment: return "自動計算下次付款"
        case .autoCalculateNextPaymentDescription: return ""
        case .selectService: return "選擇服務"
        case .searchOrCustomize: return "搜尋常見服務或自定義..."
        case .done: return "完成"
        case .ok: return "確定"
        case .startDate: return "開始日期"
        case .billingCycleLabel: return "計費週期"
        case .description: return "描述"
        case .monthlyEquivalent: return "月費換算"
        case .yearlyEquivalent: return "年費換算"
        case .editSubscription: return "編輯訂閱"
        case .updateServiceInfo: return "更新您的服務資訊"
        case .nextPaymentDate: return "下次付款日期"
        case .today: return "今天"
        case .tomorrow: return "明天"
        case .inDays: return "%d天後"
        case .daysSuffix: return "天"
        case .activeServicesCount: return "%d個訂閱服務"
        case .categoryAnalysisDescription: return "分析您的每月支出分佈"
        case .percentageOfTotal: return "%"
        case .back: return "返回"
        case .noCategorySubscriptions: return "此分類無訂閱項目"
        case .noCategorySubscriptionsDescription: return "新增此分類的訂閱即可在此查看"
        case .skip: return "跳過"
        case .next: return "下一步"
        case .getStarted: return "開始使用"
        case .enableNotifications: return "開啟通知提醒"
        case .trackSubscriptionsTitle: return "追蹤您的訂閱"
        case .trackSubscriptionsDescription: return "輕鬆管理所有月費和年費服務，再也不怕忘記取消不需要的訂閱。"
        case .analyzeSpendingTitle: return "分析支出趨勢"
        case .analyzeSpendingDescription: return "清楚了解每個月的訂閱支出分佈，幫助您做出更明智的財務決策。"
        case .smartRemindersTitle: return "智慧付款提醒"
        case .smartRemindersDescription: return "扣款前 2 天自動發送通知，避免意外扣款，讓您的財務規劃更加穩定。"
        case .minimalExperienceTitle: return "極簡使用體驗"
        case .minimalExperienceDescription: return "專注於真正重要的功能，簡潔的介面讓訂閱管理變得輕鬆愉快。"
        case .paymentReminderTitle: return "即將扣款提醒"
        case .paymentReminderBody: return "%@ 將在 2 天後扣款 %@"
        case .testNotificationTitle: return "🛠 測試通知"
        case .testNotificationBody: return "這是 %@ 的測試通知，實際會在扣款前 2 天發送。"
        case .openAppAction: return "開啟應用程式"
        case .remindLaterAction: return "稍後提醒"
        }
    }
}
