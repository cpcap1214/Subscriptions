//
//  OnboardingView.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.appColors) var appColors
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var currentPage = 0
    @Binding var isShowing: Bool
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button(String(.skip)) {
                    completeOnboarding()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(appColors.secondaryText)
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            
            // Main content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Bottom section
            VStack(spacing: 32) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? appColors.accent : appColors.border)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                
                // Action buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Final page - Get Started button
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text(.getStarted)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(appColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(appColors.accent)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Next button
                        Button(action: {
                            withAnimation(.easeInOut) {
                                currentPage += 1
                            }
                        }) {
                            Text(.next)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(appColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(appColors.accent)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(appColors.background)
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation(.easeInOut) {
            isShowing = false
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Environment(\.appColors) var appColors
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var hasRequestedPermission = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Illustration
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(appColors.secondaryBackground)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: page.iconName)
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(appColors.accent)
                }
                
                // Title and description
                VStack(spacing: 16) {
                    Text(page.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(appColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text(page.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(appColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 40)
                }
                
                // If this is the notification page, show permission request
                if page.iconName == "bell.badge" && !hasRequestedPermission {
                    Button(action: {
                        requestNotificationPermission()
                    }) {
                        Text(.enableNotifications)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(appColors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(appColors.accent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 60)
                    .padding(.top, 20)
                }
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await notificationManager.requestNotificationPermission()
            await MainActor.run {
                hasRequestedPermission = true
            }
        }
    }
}

struct OnboardingPage {
    let iconName: String
    let titleKey: LocalizationKey
    let descriptionKey: LocalizationKey
    
    var title: String {
        let localizationManager = LocalizationManager.shared
        return localizationManager.localizedString(for: titleKey)
    }
    
    var description: String {
        let localizationManager = LocalizationManager.shared
        return localizationManager.localizedString(for: descriptionKey)
    }
    
    static let allPages = [
        OnboardingPage(
            iconName: "creditcard.and.123",
            titleKey: .trackSubscriptionsTitle,
            descriptionKey: .trackSubscriptionsDescription
        ),
        OnboardingPage(
            iconName: "chart.bar.doc.horizontal",
            titleKey: .analyzeSpendingTitle,
            descriptionKey: .analyzeSpendingDescription
        ),
        OnboardingPage(
            iconName: "bell.badge",
            titleKey: .smartRemindersTitle,
            descriptionKey: .smartRemindersDescription
        ),
        OnboardingPage(
            iconName: "sparkles",
            titleKey: .minimalExperienceTitle,
            descriptionKey: .minimalExperienceDescription
        )
    ]
}

#Preview {
    OnboardingView(isShowing: .constant(true))
        .environmentObject(LocalizationManager.shared)
        .themed()
}