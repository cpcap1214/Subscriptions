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
                Button("跳過") {
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
                            Text("開始使用")
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
                            Text("下一步")
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
                        Text("開啟通知提醒")
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
    let title: String
    let description: String
    
    static let allPages = [
        OnboardingPage(
            iconName: "creditcard.and.123",
            title: "追蹤您的訂閱",
            description: "輕鬆管理所有月費和年費服務，再也不怕忘記取消不需要的訂閱。"
        ),
        OnboardingPage(
            iconName: "chart.bar.doc.horizontal",
            title: "分析支出趨勢",
            description: "清楚了解每個月的訂閱支出分佈，幫助您做出更明智的財務決策。"
        ),
        OnboardingPage(
            iconName: "bell.badge",
            title: "智慧付款提醒",
            description: "扣款前 2 天自動發送通知，避免意外扣款，讓您的財務規劃更加穩定。"
        ),
        OnboardingPage(
            iconName: "sparkles",
            title: "極簡使用體驗",
            description: "專注於真正重要的功能，簡潔的介面讓訂閱管理變得輕鬆愉快。"
        )
    ]
}

#Preview {
    OnboardingView(isShowing: .constant(true))
        .environmentObject(LocalizationManager.shared)
        .themed()
}