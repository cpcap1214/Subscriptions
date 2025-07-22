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
    
    @Published var currentLanguage: AppLanguage = .traditionalChinese {
        didSet {
            saveLanguagePreference()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "AppLanguage"
    
    private init() {
        loadLanguagePreference()
    }
    
    private func loadLanguagePreference() {
        if let languageString = userDefaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: languageString) {
            currentLanguage = language
        }
    }
    
    private func saveLanguagePreference() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
    }
    
    func localizedString(for key: LocalizationKey) -> String {
        return key.localized(for: currentLanguage)
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
    
    // Common
    case today
    case tomorrow
    case inDays
    case activeServicesCount
    
    // Stats page specific
    case categoryAnalysisDescription
    case percentageOfTotal
    
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
        case .appTitle: return "LifeOS: Subscriptions"
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
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        case .inDays: return "in %d days"
        case .activeServicesCount: return "%d active services"
        case .categoryAnalysisDescription: return "Analyze your monthly spending distribution"
        case .percentageOfTotal: return "% of total"
        }
    }
    
    private var chineseTranslation: String {
        switch self {
        case .appTitle: return "LifeOS: 訂閱管理"
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
        case .totalSubscriptionsDescription: return "個活躍服務"
        case .monthlyTotal: return "月度總計"
        case .monthlyTotalDescription: return "所有訂閱總和"
        case .yearlyTotal: return "年度總計"
        case .yearlyTotalDescription: return "年度支出預估"
        case .appVersion: return "LifeOS: 訂閱管理"
        case .madeWithCare: return "用心製作"
        case .madeWithCareDescription: return "為簡潔高效而生"
        case .addNewSubscription: return "新增訂閱"
        case .trackYourServices: return "追蹤您的月度服務"
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
        case .activeServices: return "個活躍服務"
        case .noSubscriptionsYet: return "尚無訂閱"
        case .addFirstSubscription: return "新增您的第一個訂閱開始使用"
        case .close: return "關閉"
        case .nextPaymentShort: return "下次"
        case .edit: return "編輯"
        case .delete: return "刪除"
        case .deleteConfirmTitle: return "刪除訂閱"
        case .deleteConfirmMessage: return "確定要刪除「%@」嗎？此操作無法復原。"
        case .per: return "每"
        case .appearance: return "外觀"
        case .appearanceDescription: return "選擇您偏好的主題"
        case .lightTheme: return "淺色"
        case .darkTheme: return "深色"
        case .systemTheme: return "跟隨系統"
        case .today: return "今天"
        case .tomorrow: return "明天"
        case .inDays: return "%d天後"
        case .activeServicesCount: return "%d個活躍服務"
        case .categoryAnalysisDescription: return "分析您的月度支出分佈"
        case .percentageOfTotal: return "% 佔總額"
        }
    }
}
