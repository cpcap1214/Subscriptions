//
//  LocalizedText.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct LocalizedText: View {
    let key: LocalizationKey
    @StateObject private var localizationManager = LocalizationManager.shared
    
    init(_ key: LocalizationKey) {
        self.key = key
    }
    
    var body: some View {
        Text(localizationManager.localizedString(for: key))
    }
}

// Extension to make it easier to create localized strings
extension Text {
    init(_ key: LocalizationKey) {
        let localizationManager = LocalizationManager.shared
        self.init(localizationManager.localizedString(for: key))
    }
}

// String extension for easier localization
extension String {
    init(_ key: LocalizationKey) {
        let localizationManager = LocalizationManager.shared
        self = localizationManager.localizedString(for: key)
    }
}