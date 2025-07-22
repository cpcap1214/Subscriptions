# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI-based iOS subscription management app that allows users to track their subscription services, view statistics, and manage payments. The app uses a clean, modern design with support for multiple languages (Traditional Chinese and English) and themes (light/dark/auto).

## Architecture

### Core Components
- **Models.swift**: Contains core data models (`Subscription`, `SubscriptionCategory`, `BillingCycle`, `Currency`)
- **DataManager.swift**: Singleton class managing subscription data persistence and business logic
- **ContentView.swift**: Main app structure with TabView containing Dashboard, Stats, and Settings tabs

### State Management
- Uses `@StateObject` and `@EnvironmentObject` for SwiftUI state management
- DataManager is a singleton ObservableObject that manages all subscription data
- LocalizationManager handles language switching
- ThemeManager handles appearance changes
- NotificationManager handles push notifications for payment reminders

### Key Features
- **Dashboard**: Overview of total costs and upcoming payments
- **Stats**: Category breakdown with progress bars and upcoming payments list
- **Settings**: Language, theme, currency preferences, and app information

### Data Flow
- All subscription data is stored in UserDefaults using JSON encoding/decoding
- Sample data is loaded on first launch for demo purposes
- Real-time updates through ObservableObject publishing

## Development Commands

Since this is an Xcode project, use standard Xcode commands:
- Build: Cmd+B in Xcode or `xcodebuild build -project Subscriptions.xcodeproj -scheme Subscriptions`
- Run: Cmd+R in Xcode or iOS Simulator
- Test: Cmd+U in Xcode or `xcodebuild test -project Subscriptions.xcodeproj -scheme Subscriptions -destination 'platform=iOS Simulator,name=iPhone 15'`

## Code Conventions

- Uses SwiftUI best practices with proper state management
- Follows standard Swift naming conventions
- Localized strings using custom LocalizedText enum
- Consistent spacing and typography using system fonts
- Environment values for theme colors through custom `AppColors` environment key
- Proper separation of concerns with dedicated manager classes

## Key Implementation Notes

### Stats Category Navigation
The app currently shows a placeholder alert when category rows are tapped in StatsView (line 323-329 in ContentView.swift). This is marked as "TODO: Navigate to category detail view" and needs to be implemented as a proper category detail screen.

### Sample Data
The app includes sample subscription data in Models.swift for demonstration purposes. This gets loaded on first launch if no saved data exists.

### Notification System
Uses UserNotifications framework to schedule payment reminders. Notifications are automatically managed when subscriptions are added, updated, or deleted.