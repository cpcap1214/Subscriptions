//
//  ThemeManager.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .light {
        didSet {
            saveThemePreference()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "AppTheme"
    
    private init() {
        loadThemePreference()
    }
    
    private func loadThemePreference() {
        if let themeString = userDefaults.string(forKey: themeKey),
           let theme = AppTheme(rawValue: themeString) {
            currentTheme = theme
        }
    }
    
    private func saveThemePreference() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
}

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
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
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
    
    private var chineseDisplayName: String {
        switch self {
        case .light:
            return "淺色"
        case .dark:
            return "深色"
        case .system:
            return "跟隨系統"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil // Let system decide
        }
    }
}

struct AppColors {
    let background: Color
    let secondaryBackground: Color
    let cardBackground: Color
    let primaryText: Color
    let secondaryText: Color
    let accent: Color
    let border: Color
    let destructive: Color
    
    static func colors(for theme: AppTheme) -> AppColors {
        switch theme {
        case .light, .system:
            return AppColors(
                background: .white,
                secondaryBackground: Color(.systemGray6),
                cardBackground: .white,
                primaryText: .black,
                secondaryText: .gray,
                accent: .black,
                border: Color(.systemGray4),
                destructive: .red
            )
        case .dark:
            return AppColors(
                background: Color(red: 0.11, green: 0.11, blue: 0.12), // 深灰背景 #1C1C1E
                secondaryBackground: Color(red: 0.17, green: 0.17, blue: 0.18), // 中等灰 #2C2C2E
                cardBackground: Color(red: 0.17, green: 0.17, blue: 0.18), // 卡片背景
                primaryText: Color(red: 0.98, green: 0.98, blue: 0.98), // 接近白色但不刺眼
                secondaryText: Color(red: 0.64, green: 0.64, blue: 0.67), // 淺灰文字
                accent: Color(red: 0.98, green: 0.98, blue: 0.98), // 主要強調色
                border: Color(red: 0.27, green: 0.27, blue: 0.29), // 邊框顏色
                destructive: Color(red: 1.0, green: 0.27, blue: 0.23) // 紅色
            )
        }
    }
}

// Environment key for theme colors
struct AppColorsKey: EnvironmentKey {
    static let defaultValue: AppColors = AppColors.colors(for: .light)
}

extension EnvironmentValues {
    var appColors: AppColors {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}

// View modifier to apply theme
struct ThemedViewModifier: ViewModifier {
    @ObservedObject var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.appColors, AppColors.colors(for: themeManager.currentTheme))
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

extension View {
    func themed() -> some View {
        self.modifier(ThemedViewModifier())
    }
}