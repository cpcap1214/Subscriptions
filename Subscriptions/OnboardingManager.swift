//
//  OnboardingManager.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import Foundation

class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    @Published var shouldShowOnboarding: Bool
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "hasCompletedOnboarding"
    
    private init() {
        // Check if user has completed onboarding
        self.shouldShowOnboarding = !userDefaults.bool(forKey: onboardingCompletedKey)
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: onboardingCompletedKey)
        shouldShowOnboarding = false
    }
    
    func resetOnboarding() {
        userDefaults.removeObject(forKey: onboardingCompletedKey)
        shouldShowOnboarding = true
    }
}