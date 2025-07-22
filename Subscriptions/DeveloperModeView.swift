//
//  DeveloperModeView.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct DeveloperModeView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appColors) var appColors
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var selectedSubscription: Subscription?
    @State private var showingTestNotification = false
    @State private var testNotificationCountdown = 0
    @State private var testTimer: Timer?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(appColors.secondaryText)
                                    .frame(width: 32, height: 32)
                                    .background(appColors.secondaryBackground)
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            Text("🛠 開發者模式")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(appColors.primaryText)
                            
                            Spacer()
                            
                            // Placeholder for balance
                            Color.clear.frame(width: 32, height: 32)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        Text("調試工具和測試功能")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(appColors.secondaryText)
                    }
                    
                    // Test Notification Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("📱 通知測試")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(appColors.primaryText)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("選擇要測試的訂閱")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(appColors.primaryText)
                                
                                Menu {
                                    ForEach(dataManager.subscriptions) { subscription in
                                        Button(action: {
                                            selectedSubscription = subscription
                                        }) {
                                            HStack {
                                                Image(systemName: subscription.category.iconName)
                                                Text(subscription.name)
                                                if subscription.id == selectedSubscription?.id {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: selectedSubscription?.category.iconName ?? "app.badge")
                                            .foregroundColor(appColors.primaryText)
                                            .frame(width: 20)
                                        
                                        Text(selectedSubscription?.name ?? "選擇訂閱服務...")
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(selectedSubscription != nil ? appColors.primaryText : appColors.secondaryText)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(appColors.secondaryText)
                                            .font(.system(size: 12))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(appColors.secondaryBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(appColors.border, lineWidth: 1)
                                    )
                                }
                            }
                            
                            if let subscription = selectedSubscription {
                                Button(action: {
                                    startTestNotification()
                                }) {
                                    HStack {
                                        Image(systemName: testNotificationCountdown > 0 ? "timer" : "bell.badge")
                                            .font(.system(size: 14))
                                        
                                        if testNotificationCountdown > 0 {
                                            Text("通知發送中... \\(testNotificationCountdown)s")
                                        } else {
                                            Text("發送 5 秒後測試通知")
                                        }
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(testNotificationCountdown > 0 ? appColors.secondaryText : appColors.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(testNotificationCountdown > 0 ? appColors.secondaryBackground : appColors.accent)
                                    .cornerRadius(12)
                                }
                                .disabled(testNotificationCountdown > 0)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Notification Status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🔔 通知狀態")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(appColors.primaryText)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("通知權限")
                                Spacer()
                                Text(notificationManager.isNotificationEnabled ? "已開啟" : "未開啟")
                                    .foregroundColor(notificationManager.isNotificationEnabled ? .green : .red)
                            }
                            
                            Button("查看待發送通知") {
                                notificationManager.printPendingNotifications()
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(appColors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(appColors.secondaryBackground)
                            .cornerRadius(8)
                        }
                        .padding(16)
                        .background(appColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(appColors.border, lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    // JSON Data Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("📋 訂閱資料 (JSON)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(appColors.primaryText)
                            .padding(.horizontal, 24)
                        
                        ScrollView {
                            Text(formattedJSON)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(appColors.secondaryText)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 300)
                        .background(appColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(appColors.border, lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(appColors.background)
            .navigationBarHidden(true)
        }
        .onDisappear {
            stopTestTimer()
        }
    }
    
    private var formattedJSON: String {
        do {
            let jsonData = try JSONEncoder().encode(dataManager.subscriptions)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: prettyJsonData, encoding: .utf8) ?? "JSON 編碼失敗"
        } catch {
            return "JSON 編碼錯誤: \\(error.localizedDescription)"
        }
    }
    
    private func startTestNotification() {
        guard let subscription = selectedSubscription else { return }
        
        testNotificationCountdown = 5
        
        testTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            testNotificationCountdown -= 1
            
            if testNotificationCountdown <= 0 {
                timer.invalidate()
                sendTestNotification(for: subscription)
            }
        }
    }
    
    private func stopTestTimer() {
        testTimer?.invalidate()
        testTimer = nil
        testNotificationCountdown = 0
    }
    
    private func sendTestNotification(for subscription: Subscription) {
        notificationManager.scheduleTestNotification(for: subscription, delaySeconds: 1.0)
    }
}

#Preview {
    DeveloperModeView()
        .environmentObject(DataManager.shared)
        .themed()
}