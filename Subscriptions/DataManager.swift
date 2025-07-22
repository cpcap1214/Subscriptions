//
//  DataManager.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let subscriptionsKey = "SavedSubscriptions"
    private let preferredCurrencyKey = "PreferredCurrency"
    private let notificationManager = NotificationManager.shared
    
    @Published var subscriptions: [Subscription] = []
    @Published var preferredCurrency: Currency = .twd
    
    private init() {
        loadSubscriptions()
        loadPreferredCurrency()
    }
    
    // MARK: - Subscription Management
    
    func loadSubscriptions() {
        if let data = userDefaults.data(forKey: subscriptionsKey) {
            do {
                let decodedSubscriptions = try JSONDecoder().decode([Subscription].self, from: data)
                DispatchQueue.main.async {
                    self.subscriptions = decodedSubscriptions
                }
            } catch {
                print("Error decoding subscriptions: \(error)")
                // If decoding fails, load sample data
                DispatchQueue.main.async {
                    self.subscriptions = Subscription.sampleData
                }
            }
        } else {
            // First time launch - check if onboarding is completed
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            if hasCompletedOnboarding {
                // User has completed onboarding but no subscriptions saved, start empty
                DispatchQueue.main.async {
                    self.subscriptions = []
                }
            } else {
                // First time launch - load sample data for demo
                DispatchQueue.main.async {
                    self.subscriptions = Subscription.sampleData
                    self.saveSubscriptions()
                }
            }
        }
    }
    
    func saveSubscriptions() {
        do {
            let encodedData = try JSONEncoder().encode(subscriptions)
            userDefaults.set(encodedData, forKey: subscriptionsKey)
        } catch {
            print("Error encoding subscriptions: \(error)")
        }
    }
    
    func addSubscription(_ subscription: Subscription) {
        DispatchQueue.main.async {
            self.subscriptions.append(subscription)
            self.saveSubscriptions()
            self.notificationManager.scheduleNotification(for: subscription)
        }
    }
    
    func updateSubscription(_ subscription: Subscription) {
        DispatchQueue.main.async {
            if let index = self.subscriptions.firstIndex(where: { $0.id == subscription.id }) {
                // Cancel old notification
                self.notificationManager.cancelNotification(for: self.subscriptions[index])
                // Update subscription
                self.subscriptions[index] = subscription
                self.saveSubscriptions()
                // Schedule new notification
                if subscription.isActive {
                    self.notificationManager.scheduleNotification(for: subscription)
                }
            }
        }
    }
    
    func deleteSubscription(at indexSet: IndexSet) {
        DispatchQueue.main.async {
            // Cancel notifications for deleted subscriptions
            for index in indexSet {
                if self.subscriptions.indices.contains(index) {
                    self.notificationManager.cancelNotification(for: self.subscriptions[index])
                }
            }
            self.subscriptions.remove(atOffsets: indexSet)
            self.saveSubscriptions()
        }
    }
    
    func deleteSubscription(_ subscription: Subscription) {
        DispatchQueue.main.async {
            // Cancel notification for deleted subscription
            self.notificationManager.cancelNotification(for: subscription)
            self.subscriptions.removeAll { $0.id == subscription.id }
            self.saveSubscriptions()
        }
    }
    
    // MARK: - Notification Management
    
    func rescheduleAllNotifications() {
        notificationManager.rescheduleAllNotifications(for: activeSubscriptions)
    }
    
    // MARK: - Currency Management
    
    func loadPreferredCurrency() {
        if let currencyString = userDefaults.string(forKey: preferredCurrencyKey),
           let currency = Currency(rawValue: currencyString) {
            DispatchQueue.main.async {
                self.preferredCurrency = currency
            }
        }
    }
    
    func savePreferredCurrency(_ currency: Currency) {
        userDefaults.set(currency.rawValue, forKey: preferredCurrencyKey)
        DispatchQueue.main.async {
            self.preferredCurrency = currency
        }
    }
    
    // MARK: - Computed Properties
    
    var activeSubscriptions: [Subscription] {
        return subscriptions.filter { $0.isActive }
    }
    
    var totalMonthlyCost: Double {
        return activeSubscriptions.reduce(0) { $0 + $1.monthlyCost }
    }
    
    var nextUpcomingPayment: Subscription? {
        return activeSubscriptions
            .filter { $0.nextPaymentDate >= Date() }
            .min { $0.nextPaymentDate < $1.nextPaymentDate }
    }
    
    func totalCostForCategory(_ category: SubscriptionCategory) -> Double {
        return activeSubscriptions
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.monthlyCost }
    }
    
    func subscriptionsForCategory(_ category: SubscriptionCategory) -> [Subscription] {
        return activeSubscriptions.filter { $0.category == category }
    }
    
    // MARK: - Statistics
    
    func totalYearlyCost() -> Double {
        return totalMonthlyCost * 12
    }
    
    func categoriesWithCosts() -> [(category: SubscriptionCategory, cost: Double)] {
        let categories = SubscriptionCategory.allCases
        return categories.compactMap { category in
            let cost = totalCostForCategory(category)
            return cost > 0 ? (category, cost) : nil
        }.sorted { $0.cost > $1.cost }
    }
    
    func upcomingPayments(nextDays: Int = 30) -> [Subscription] {
        let endDate = Calendar.current.date(byAdding: .day, value: nextDays, to: Date()) ?? Date()
        return activeSubscriptions
            .filter { $0.nextPaymentDate >= Date() && $0.nextPaymentDate <= endDate }
            .sorted { $0.nextPaymentDate < $1.nextPaymentDate }
    }
    
    // MARK: - Currency Formatting
    
    func formattedCurrency(_ amount: Double, currency: String? = nil) -> String {
        let currencyToUse = currency ?? preferredCurrency.rawValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyToUse
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            let currency = Currency(rawValue: currencyToUse) ?? .usd
            return "\(currency.symbol)\(String(format: "%.2f", amount))"
        }
    }
}