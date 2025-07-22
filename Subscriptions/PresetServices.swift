//
//  PresetServices.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import Foundation

struct PresetService {
    let name: String
    let defaultCost: Double
    let defaultCurrency: String
    let category: SubscriptionCategory
    let iconName: String
    let description: String
    let defaultBillingCycle: BillingCycle
    
    static let allServices = [
        // 按字母順序排列
        PresetService(
            name: "Adobe Creative Cloud",
            defaultCost: 52.99,
            defaultCurrency: "USD",
            category: .productivity,
            iconName: "paintbrush",
            description: "創意軟體套件",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Amazon Prime Video",
            defaultCost: 8.99,
            defaultCurrency: "USD",
            category: .streaming,
            iconName: "tv",
            description: "影片串流服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Apple Fitness+",
            defaultCost: 9.99,
            defaultCurrency: "USD",
            category: .health,
            iconName: "figure.walk",
            description: "健身訓練服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Apple Music",
            defaultCost: 9.99,
            defaultCurrency: "USD",
            category: .music,
            iconName: "music.note",
            description: "音樂串流服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Canva Pro",
            defaultCost: 12.99,
            defaultCurrency: "USD",
            category: .productivity,
            iconName: "paintbrush.pointed",
            description: "設計工具",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Coursera Plus",
            defaultCost: 59.00,
            defaultCurrency: "USD",
            category: .education,
            iconName: "graduationcap",
            description: "線上課程平台",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Disney+",
            defaultCost: 7.99,
            defaultCurrency: "USD",
            category: .streaming,
            iconName: "tv",
            description: "迪士尼影片串流",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Dropbox Plus",
            defaultCost: 9.99,
            defaultCurrency: "USD",
            category: .utilities,
            iconName: "icloud",
            description: "雲端儲存服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Figma Professional",
            defaultCost: 12.00,
            defaultCurrency: "USD",
            category: .productivity,
            iconName: "rectangle.on.rectangle",
            description: "設計協作工具",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "GitHub Pro",
            defaultCost: 4.00,
            defaultCurrency: "USD",
            category: .business,
            iconName: "chevron.left.forwardslash.chevron.right",
            description: "程式碼託管服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Google One",
            defaultCost: 1.99,
            defaultCurrency: "USD",
            category: .utilities,
            iconName: "icloud",
            description: "雲端儲存服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "HBO Max",
            defaultCost: 14.99,
            defaultCurrency: "USD",
            category: .streaming,
            iconName: "tv",
            description: "影片串流服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "iCloud+",
            defaultCost: 2.99,
            defaultCurrency: "USD",
            category: .utilities,
            iconName: "icloud",
            description: "雲端儲存服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "MasterClass",
            defaultCost: 15.00,
            defaultCurrency: "USD",
            category: .education,
            iconName: "graduationcap",
            description: "專業技能學習",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Microsoft 365",
            defaultCost: 6.99,
            defaultCurrency: "USD",
            category: .productivity,
            iconName: "doc.text",
            description: "辦公軟體套件",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Netflix",
            defaultCost: 15.99,
            defaultCurrency: "USD",
            category: .streaming,
            iconName: "tv",
            description: "影片串流服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Notion Pro",
            defaultCost: 8.00,
            defaultCurrency: "USD",
            category: .productivity,
            iconName: "note.text",
            description: "筆記協作工具",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "PlayStation Plus",
            defaultCost: 9.99,
            defaultCurrency: "USD",
            category: .gaming,
            iconName: "gamecontroller",
            description: "遊戲訂閱服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Spotify Premium",
            defaultCost: 9.99,
            defaultCurrency: "USD",
            category: .music,
            iconName: "music.note",
            description: "音樂串流服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "Xbox Game Pass Ultimate",
            defaultCost: 14.99,
            defaultCurrency: "USD",
            category: .gaming,
            iconName: "gamecontroller",
            description: "遊戲訂閱服務",
            defaultBillingCycle: .monthly
        ),
        PresetService(
            name: "YouTube Music",
            defaultCost: 9.99,
            defaultCurrency: "USD",
            category: .music,
            iconName: "music.note",
            description: "音樂串流服務",
            defaultBillingCycle: .monthly
        )
    ]
    
    static func searchServices(_ query: String) -> [PresetService] {
        guard !query.isEmpty else { return allServices }
        
        return allServices.filter { service in
            service.name.localizedCaseInsensitiveContains(query) ||
            service.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    func toSubscription(nextPaymentDate: Date) -> Subscription {
        return Subscription(
            name: name,
            cost: defaultCost,
            currency: defaultCurrency,
            billingCycle: defaultBillingCycle,
            nextPaymentDate: nextPaymentDate,
            category: category,
            description: description
        )
    }
}