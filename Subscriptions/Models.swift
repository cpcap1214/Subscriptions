//
//  Models.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import Foundation

struct Subscription: Codable, Identifiable {
    let id: UUID
    var name: String
    var cost: Double
    var currency: String
    var billingCycle: BillingCycle
    var nextPaymentDate: Date
    var category: SubscriptionCategory
    var description: String?
    var isActive: Bool
    
    init(name: String, cost: Double, currency: String = "USD", billingCycle: BillingCycle, nextPaymentDate: Date, category: SubscriptionCategory, description: String? = nil, isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.cost = cost
        self.currency = currency
        self.billingCycle = billingCycle
        self.nextPaymentDate = nextPaymentDate
        self.category = category
        self.description = description
        self.isActive = isActive
    }
    
    init(id: UUID, name: String, cost: Double, currency: String = "USD", billingCycle: BillingCycle, nextPaymentDate: Date, category: SubscriptionCategory, description: String? = nil, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.cost = cost
        self.currency = currency
        self.billingCycle = billingCycle
        self.nextPaymentDate = nextPaymentDate
        self.category = category
        self.description = description
        self.isActive = isActive
    }
    
    var monthlyCost: Double {
        switch billingCycle {
        case .weekly:
            return cost * 4.33 // Average weeks per month
        case .monthly:
            return cost
        case .quarterly:
            return cost / 3
        case .semiAnnually:
            return cost / 6
        case .annually:
            return cost / 12
        }
    }
    
    func nextPaymentDateAfter(_ date: Date) -> Date {
        var components = DateComponents()
        
        switch billingCycle {
        case .weekly:
            components.weekOfYear = 1
        case .monthly:
            components.month = 1
        case .quarterly:
            components.month = 3
        case .semiAnnually:
            components.month = 6
        case .annually:
            components.year = 1
        }
        
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }
}

enum BillingCycle: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnually = "Semi-annually"
    case annually = "Annually"
    
    var displayName: String {
        let localizationManager = LocalizationManager.shared
        switch localizationManager.currentLanguage {
        case .traditionalChinese:
            return chineseDisplayName
        case .english:
            return rawValue
        }
    }
    
    private var chineseDisplayName: String {
        switch self {
        case .weekly:
            return "每週"
        case .monthly:
            return "每月"
        case .quarterly:
            return "每季"
        case .semiAnnually:
            return "每半年"
        case .annually:
            return "每年"
        }
    }
    
    var shortDisplayName: String {
        let localizationManager = LocalizationManager.shared
        switch localizationManager.currentLanguage {
        case .traditionalChinese:
            return chineseShortDisplayName
        case .english:
            return englishShortDisplayName
        }
    }
    
    private var englishShortDisplayName: String {
        switch self {
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        case .quarterly:
            return "3 months"
        case .semiAnnually:
            return "6 months"
        case .annually:
            return "year"
        }
    }
    
    private var chineseShortDisplayName: String {
        switch self {
        case .weekly:
            return "週"
        case .monthly:
            return "月"
        case .quarterly:
            return "季"
        case .semiAnnually:
            return "半年"
        case .annually:
            return "年"
        }
    }
}

enum SubscriptionCategory: String, CaseIterable, Codable {
    case entertainment = "Entertainment"
    case productivity = "Productivity"
    case finance = "Finance"
    case health = "Health & Fitness"
    case education = "Education"
    case news = "News & Magazines"
    case music = "Music"
    case streaming = "Video Streaming"
    case gaming = "Gaming"
    case business = "Business"
    case utilities = "Utilities"
    case other = "Other"
    
    var displayName: String {
        let localizationManager = LocalizationManager.shared
        switch localizationManager.currentLanguage {
        case .traditionalChinese:
            return chineseDisplayName
        case .english:
            return rawValue
        }
    }
    
    private var chineseDisplayName: String {
        switch self {
        case .entertainment:
            return "娛樂"
        case .productivity:
            return "生產力"
        case .finance:
            return "金融"
        case .health:
            return "健康與健身"
        case .education:
            return "教育"
        case .news:
            return "新聞與雜誌"
        case .music:
            return "音樂"
        case .streaming:
            return "影音串流"
        case .gaming:
            return "遊戲"
        case .business:
            return "商業"
        case .utilities:
            return "工具"
        case .other:
            return "其他"
        }
    }
    
    var iconName: String {
        switch self {
        case .entertainment:
            return "tv"
        case .productivity:
            return "hammer"
        case .finance:
            return "dollarsign.circle"
        case .health:
            return "heart"
        case .education:
            return "book"
        case .news:
            return "newspaper"
        case .music:
            return "music.note"
        case .streaming:
            return "play.rectangle"
        case .gaming:
            return "gamecontroller"
        case .business:
            return "briefcase"
        case .utilities:
            return "wrench.and.screwdriver"
        case .other:
            return "folder"
        }
    }
}

enum Currency: String, CaseIterable, Codable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case twd = "TWD"
    
    var symbol: String {
        switch self {
        case .usd:
            return "$"
        case .eur:
            return "€"
        case .gbp:
            return "£"
        case .jpy:
            return "¥"
        case .twd:
            return "NT$"
        }
    }
    
    var displayName: String {
        let localizationManager = LocalizationManager.shared
        switch localizationManager.currentLanguage {
        case .traditionalChinese:
            return chineseDisplayName
        case .english:
            return englishDisplayName
        }
    }
    
    private var englishDisplayName: String {
        switch self {
        case .usd:
            return "US Dollar"
        case .eur:
            return "Euro"
        case .gbp:
            return "British Pound"
        case .jpy:
            return "Japanese Yen"
        case .twd:
            return "Taiwan Dollar"
        }
    }
    
    private var chineseDisplayName: String {
        switch self {
        case .usd:
            return "美元"
        case .eur:
            return "歐元"
        case .gbp:
            return "英鎊"
        case .jpy:
            return "日圓"
        case .twd:
            return "新台幣"
        }
    }
}

extension Subscription {
    static let sampleData: [Subscription] = []
}