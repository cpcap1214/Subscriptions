//
//  ContentView.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text(.dashboard)
                }
                .tag(0)
            
            StatsView()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "chart.bar.fill" : "chart.bar")
                    Text(.stats)
                }
                .tag(1)
            
            SettingsView()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                    Text(.settings)
                }
                .tag(2)
        }
        .themed()
        .fullScreenCover(isPresented: $onboardingManager.shouldShowOnboarding) {
            OnboardingView(isShowing: $onboardingManager.shouldShowOnboarding)
                .environmentObject(localizationManager)
                .themed()
        }
        .onAppear {
            // Setup notification categories when app launches
            notificationManager.setupNotificationCategories()
            notificationManager.checkNotificationStatus()
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.appColors) var appColors
    @State private var showingAddSubscription = false
    @State private var showingAllSubscriptions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(.appTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(appColors.primaryText)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                // Main Content
                VStack(spacing: 48) {
                    // Total Section
                    VStack(spacing: 8) {
                        Text(.total)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(appColors.secondaryText)
                        
                        Text(dataManager.formattedCurrency(dataManager.totalMonthlyCost))
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(appColors.primaryText)
                            .tracking(-1)
                        
                        Text(.thisMonth)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(appColors.secondaryText)
                    }
                    
                    // Next Payment
                    VStack(spacing: 8) {
                        Text(.nextPayment)
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundColor(appColors.secondaryText)
                            .tracking(0.5)
                        
                        if let nextPayment = dataManager.nextUpcomingPayment {
                            Text("\(nextPayment.nextPaymentDate, formatter: DateFormatter.shortDate) · \(nextPayment.name)")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(appColors.primaryText)
                        } else {
                            Text(.noUpcomingPayments)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(appColors.secondaryText)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(appColors.secondaryBackground)
                    .cornerRadius(12)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingAllSubscriptions = true
                        }) {
                            Text(.viewAllSubscriptions)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(appColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(appColors.accent)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            showingAddSubscription = true
                        }) {
                            Text(.addSubscription)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(appColors.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(appColors.secondaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(appColors.border, lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(appColors.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView()
                    .environmentObject(dataManager)
                    .environmentObject(localizationManager)
            }
            .sheet(isPresented: $showingAllSubscriptions) {
                AllSubscriptionsView()
                    .environmentObject(dataManager)
                    .environmentObject(localizationManager)
            }
        }
    }
}

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.appColors) var appColors
    @State private var selectedCategory: SubscriptionCategory? = nil
    @State private var showingCategoryDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text(.stats)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(appColors.primaryText)
                    }
                    
                    // Overview Cards
                    HStack(spacing: 16) {
                        StatCardView(
                            title: String(.monthly),
                            value: dataManager.formattedCurrency(dataManager.totalMonthlyCost),
                            icon: "calendar"
                        )
                        
                        StatCardView(
                            title: String(.yearly),
                            value: dataManager.formattedCurrency(dataManager.totalYearlyCost()),
                            icon: "calendar.badge.clock"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Categories Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Section Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(.byCategory)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(appColors.primaryText)
                            
                            Text(.categoryAnalysisDescription)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(appColors.secondaryText)
                        }
                        .padding(.horizontal, 24)
                        
                        // Categories List with Card Background
                        VStack(spacing: 12) {
                            ForEach(dataManager.categoriesWithCosts(), id: \.category) { item in
                                CategoryRowView(
                                    category: item.category,
                                    cost: item.cost,
                                    totalCost: dataManager.totalMonthlyCost
                                ) {
                                    selectedCategory = item.category
                                    showingCategoryDetail = true
                                }
                                .background(appColors.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(appColors.border, lineWidth: 0.5)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Divider with subtle styling
                    VStack {
                        Rectangle()
                            .fill(appColors.border)
                            .frame(height: 1)
                            .opacity(0.3)
                    }
                    .padding(.horizontal, 40)
                    
                    // Upcoming Payments Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Section Header with clear separation
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(.upcomingPayments))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(appColors.primaryText)
                            
                            Text(String(.upcomingPaymentsDescription))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(appColors.secondaryText)
                        }
                        .padding(.horizontal, 24)
                        
                        let upcomingPayments = dataManager.upcomingPayments()
                        
                        if upcomingPayments.isEmpty {
                            // Empty state with better styling
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 32))
                                    .foregroundColor(appColors.secondaryText)
                                    .opacity(0.6)
                                
                                Text(.noUpcomingPaymentsStats)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(appColors.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(appColors.secondaryBackground)
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                        } else {
                            // Payments List with improved layout
                            VStack(spacing: 1) {
                                ForEach(Array(upcomingPayments.enumerated()), id: \.element.id) { index, subscription in
                                    UpcomingPaymentRowView(subscription: subscription)
                                        .background(appColors.cardBackground)
                                        .overlay(
                                            // Add subtle divider between items (except last)
                                            Group {
                                                if index < upcomingPayments.count - 1 {
                                                    VStack {
                                                        Spacer()
                                                        Rectangle()
                                                            .fill(appColors.border)
                                                            .frame(height: 0.5)
                                                            .opacity(0.3)
                                                            .padding(.horizontal, 20)
                                                    }
                                                }
                                            }
                                        )
                                }
                            }
                            .background(appColors.cardBackground)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(appColors.border, lineWidth: 0.5)
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .background(appColors.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCategoryDetail) {
                CategoryDetailView(category: selectedCategory!)
                    .environmentObject(dataManager)
                    .environmentObject(localizationManager)
                    .themed()
            }
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    @Environment(\.appColors) var appColors
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(appColors.secondaryText)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(appColors.primaryText)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(appColors.secondaryText)
        }
        .padding(16)
        .background(appColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(appColors.border, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct CategoryRowView: View {
    let category: SubscriptionCategory
    let cost: Double
    let totalCost: Double
    let onTap: () -> Void
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.appColors) var appColors
    @State private var isPressed = false
    
    private var percentage: Double {
        guard totalCost > 0 else { return 0 }
        return (cost / totalCost) * 100
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Top row with icon, name, and amount
                HStack(spacing: 16) {
                    // Category Icon with background
                    ZStack {
                        Circle()
                            .fill(appColors.secondaryBackground)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: category.iconName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(appColors.primaryText)
                    }
                    
                    // Category info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(appColors.primaryText)
                        
                        Text("\(Int(percentage))\(String(.percentageOfTotal))")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(appColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Amount and arrow
                    HStack(spacing: 8) {
                        Text(dataManager.formattedCurrency(cost))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(appColors.primaryText)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(appColors.secondaryText)
                            .opacity(0.6)
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(appColors.border)
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(appColors.accent)
                            .frame(width: max(4, geometry.size.width * (percentage / 100)), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(CategoryButtonStyle(isPressed: $isPressed, appColors: appColors))
    }
}

struct CategoryButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    let appColors: AppColors
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? appColors.secondaryBackground : Color.clear)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                isPressed = pressed
            }
    }
}

struct UpcomingPaymentRowView: View {
    let subscription: Subscription
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.appColors) var appColors
    
    private var daysUntilPayment: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let paymentDate = calendar.startOfDay(for: subscription.nextPaymentDate)
        return calendar.dateComponents([.day], from: today, to: paymentDate).day ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Top row: Service name and amount
            HStack {
                // Service icon and name
                HStack(spacing: 12) {
                    Image(systemName: subscription.category.iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(appColors.primaryText)
                        .frame(width: 24, height: 24)
                        .background(appColors.secondaryBackground)
                        .clipShape(Circle())
                    
                    Text(subscription.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(appColors.primaryText)
                }
                
                Spacer()
                
                // Amount
                Text(dataManager.formattedCurrency(subscription.cost, currency: subscription.currency))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(appColors.primaryText)
            }
            
            // Bottom row: Date and countdown with better separation
            HStack {
                // Payment date
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(appColors.secondaryText)
                    
                    Text("\(subscription.nextPaymentDate, formatter: DateFormatter.shortDate)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(appColors.secondaryText)
                }
                
                Spacer()
                
                // Countdown
                HStack(spacing: 6) {
                    Image(systemName: daysUntilPayment <= 3 ? "exclamationmark.triangle.fill" : "clock")
                        .font(.system(size: 12))
                        .foregroundColor(daysUntilPayment <= 3 ? appColors.destructive : appColors.secondaryText)
                    
                    Text(daysUntilPayment == 0 ? String(.today) : daysUntilPayment == 1 ? String(.tomorrow) : String(.inDays).replacingOccurrences(of: "%d", with: "\(daysUntilPayment)"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(daysUntilPayment <= 3 ? appColors.destructive : appColors.secondaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(daysUntilPayment <= 3 ? appColors.destructive.opacity(0.1) : appColors.secondaryBackground)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.appColors) var appColors
    
    @State private var developerTapCount = 0
    @State private var showingDeveloperMode = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Button(action: {
                            handleDeveloperTap()
                        }) {
                            Text(.settings)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(appColors.primaryText)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    VStack(spacing: 24) {
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(.preferences)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                SettingsRowView(
                                    icon: "globe",
                                    title: String(.language)
                                ) {
                                    Menu {
                                        ForEach(AppLanguage.allCases, id: \.self) { language in
                                            Button(action: {
                                                localizationManager.currentLanguage = language
                                            }) {
                                                HStack {
                                                    Text(language.nativeName)
                                                    if language == localizationManager.currentLanguage {
                                                        Spacer()
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(localizationManager.currentLanguage.displayName)
                                                .font(.system(size: 14, weight: .regular))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 10))
                                        }
                                        .foregroundColor(appColors.primaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(appColors.secondaryBackground)
                                        .cornerRadius(8)
                                    }
                                }
                                
                                Divider()
                                    .padding(.horizontal, 64)
                                
                                SettingsRowView(
                                    icon: "paintbrush",
                                    title: String(.appearance)
                                ) {
                                    Menu {
                                        ForEach(AppTheme.allCases, id: \.self) { theme in
                                            Button(action: {
                                                themeManager.currentTheme = theme
                                            }) {
                                                HStack {
                                                    Text(theme.displayName)
                                                    if theme == themeManager.currentTheme {
                                                        Spacer()
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(themeManager.currentTheme.displayName)
                                                .font(.system(size: 14, weight: .regular))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 10))
                                        }
                                        .foregroundColor(appColors.primaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(appColors.secondaryBackground)
                                        .cornerRadius(8)
                                    }
                                }
                                
                                Divider()
                                    .padding(.horizontal, 64)
                                
                                SettingsRowView(
                                    icon: "bell",
                                    title: "付款提醒"
                                ) {
                                    Toggle("", isOn: Binding(
                                        get: { notificationManager.isNotificationEnabled },
                                        set: { newValue in
                                            if newValue {
                                                Task {
                                                    let granted = await notificationManager.requestNotificationPermission()
                                                    if granted {
                                                        dataManager.rescheduleAllNotifications()
                                                    }
                                                }
                                            } else {
                                                notificationManager.isNotificationEnabled = false
                                                notificationManager.cancelAllNotifications()
                                            }
                                        }
                                    ))
                                    .toggleStyle(SwitchToggleStyle())
                                }
                                
                                Divider()
                                    .padding(.horizontal, 64)
                                
                                SettingsRowView(
                                    icon: "dollarsign.circle",
                                    title: String(.preferredCurrency)
                                ) {
                                    Menu {
                                        ForEach(Currency.allCases, id: \.self) { currency in
                                            Button(action: {
                                                dataManager.savePreferredCurrency(currency)
                                            }) {
                                                HStack {
                                                    Text(currency.symbol)
                                                        .font(.system(size: 14, weight: .semibold))
                                                    Text(currency.displayName)
                                                        .font(.system(size: 14, weight: .regular))
                                                    if currency == dataManager.preferredCurrency {
                                                        Spacer()
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text("\(dataManager.preferredCurrency.symbol) \(dataManager.preferredCurrency.displayName)")
                                                .font(.system(size: 14, weight: .regular))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 10))
                                        }
                                        .foregroundColor(appColors.primaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(appColors.secondaryBackground)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .background(appColors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(appColors.border, lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                        }
                        
                        // Data Overview Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(.dataOverview)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                SettingsRowView(
                                    icon: "chart.bar",
                                    title: String(.totalSubscriptions)
                                ) {
                                    Text("\(dataManager.activeSubscriptions.count) \(String(.totalSubscriptionsDescription))")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(appColors.primaryText)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 64)
                                
                                SettingsRowView(
                                    icon: "calendar",
                                    title: String(.monthlyTotal)
                                ) {
                                    Text(dataManager.formattedCurrency(dataManager.totalMonthlyCost))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(appColors.primaryText)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 64)
                                
                                SettingsRowView(
                                    icon: "creditcard",
                                    title: String(.yearlyTotal)
                                ) {
                                    Text(dataManager.formattedCurrency(dataManager.totalYearlyCost()))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(appColors.primaryText)
                                }
                            }
                            .background(appColors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(appColors.border, lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                        }
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(.about)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                SettingsRowView(
                                    icon: "info.circle",
                                    title: String(.appVersion)
                                ) {
                                    Text("1.0.0")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(appColors.secondaryText)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 64)
                                Button(action: {
                                    onboardingManager.resetOnboarding()
                                }) {
                                    SettingsRowView(
                                        icon: "arrow.clockwise",
                                        title: "重新觀看導覽"
                                    ) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(appColors.secondaryText)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .background(appColors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(appColors.border, lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 32)
            }
            .background(appColors.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDeveloperMode) {
                DeveloperModeView()
                    .environmentObject(dataManager)
                    .themed()
            }
        }
    }
    
    private func handleDeveloperTap() {
        developerTapCount += 1
        
        if developerTapCount >= 10 {
            showingDeveloperMode = true
            developerTapCount = 0
        }
        
        // Reset counter after 3 seconds of no taps
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if developerTapCount < 10 {
                developerTapCount = 0
            }
        }
    }
}

struct SettingsRowView<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    @Environment(\.appColors) var appColors
    
    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(appColors.primaryText)
                .frame(width: 24, height: 24)
                .background(appColors.secondaryBackground)
                .clipShape(Circle())
                .padding(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(appColors.primaryText)
            }
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct CategoryDetailView: View {
    let category: SubscriptionCategory
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.appColors) var appColors
    @Environment(\.dismiss) var dismiss
    
    private var categorySubscriptions: [Subscription] {
        dataManager.activeSubscriptions.filter { $0.category == category }
    }
    
    private var totalCategoryCost: Double {
        categorySubscriptions.reduce(0) { $0 + $1.cost }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    // Category icon and name
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(appColors.secondaryBackground)
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: category.iconName)
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(appColors.primaryText)
                        }
                        
                        Text(category.displayName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(appColors.primaryText)
                    }
                    
                    // Category stats
                    VStack(spacing: 8) {
                        Text(dataManager.formattedCurrency(totalCategoryCost))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(appColors.primaryText)
                        
                        Text("\(categorySubscriptions.count) 項服務")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(appColors.secondaryText)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 32)
                .padding(.horizontal, 24)
                
                // Subscriptions list
                if categorySubscriptions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(appColors.secondaryText)
                            .opacity(0.6)
                        
                        Text("此分類暫無訂閱服務")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(appColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(appColors.background)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(categorySubscriptions) { subscription in
                                CategorySubscriptionRowView(subscription: subscription)
                                    .background(appColors.cardBackground)
                            }
                        }
                        .background(appColors.cardBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(appColors.border, lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                    }
                    .background(appColors.background)
                }
            }
            .background(appColors.background)
            .navigationTitle(category.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(appColors.accent)
                }
            }
        }
    }
}

struct CategorySubscriptionRowView: View {
    let subscription: Subscription
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.appColors) var appColors
    
    var body: some View {
        HStack(spacing: 16) {
            // Service name and next payment
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(appColors.primaryText)
                
                Text("下次付款：\(subscription.nextPaymentDate, formatter: DateFormatter.shortDate)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(appColors.secondaryText)
            }
            
            Spacer()
            
            // Cost and frequency
            VStack(alignment: .trailing, spacing: 4) {
                Text(dataManager.formattedCurrency(subscription.cost, currency: subscription.currency))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(appColors.primaryText)
                
                Text(subscription.billingCycle.displayName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(appColors.secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    ContentView()
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
