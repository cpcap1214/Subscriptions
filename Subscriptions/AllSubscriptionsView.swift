//
//  AllSubscriptionsView.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct AllSubscriptionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appColors) var appColors
    @State private var showingAddSubscription = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Minimal Header
                    VStack(spacing: 20) {
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
                            
                            Text(.allSubscriptions)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddSubscription = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(appColors.background)
                                    .frame(width: 32, height: 32)
                                    .background(appColors.accent)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Simple count indicator
                        Text("\(dataManager.activeSubscriptions.count) services")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(appColors.secondaryText)
                            .padding(.bottom, 8)
                    }
                    
                    // Simple Subscriptions List
                    if dataManager.subscriptions.isEmpty {
                        VStack(spacing: 24) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundColor(appColors.secondaryText)
                                .opacity(0.4)
                            
                            VStack(spacing: 8) {
                                Text(.noSubscriptionsYet)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(appColors.primaryText)
                                
                                Text(.addFirstSubscription)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(appColors.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 80)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(dataManager.subscriptions.enumerated()), id: \.element.id) { index, subscription in
                                VStack(spacing: 0) {
                                    MinimalSubscriptionRowView(subscription: subscription)
                                        .environmentObject(dataManager)
                                    
                                    // Add divider between items (except last)
                                    if index < dataManager.subscriptions.count - 1 {
                                        Rectangle()
                                            .fill(appColors.border)
                                            .frame(height: 0.5)
                                            .opacity(0.3)
                                            .padding(.leading, 60) // Indent to align with content
                                    }
                                }
                            }
                        }
                        .background(appColors.cardBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(appColors.border, lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .background(appColors.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView()
                    .environmentObject(dataManager)
            }
        }
    }
}

struct MinimalSubscriptionRowView: View {
    let subscription: Subscription
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.appColors) var appColors
    @State private var showingDeleteAlert = false
    @State private var showingActions = false
    @State private var showingEditSubscription = false
    
    private var daysUntilPayment: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let paymentDate = calendar.startOfDay(for: subscription.nextPaymentDate)
        return calendar.dateComponents([.day], from: today, to: paymentDate).day ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                showingActions.toggle()
            }) {
                HStack(spacing: 16) {
                    // Service icon (smaller, simpler)
                    Image(systemName: subscription.category.iconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(appColors.secondaryText)
                        .frame(width: 24, height: 24)
                    
                    // Service name and details
                    VStack(alignment: .leading, spacing: 2) {
                        Text(subscription.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(appColors.primaryText)
                        
                        HStack(spacing: 4) {
                            Text(subscription.billingCycle.shortDisplayName)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(appColors.secondaryText)
                            
                            Text("•")
                                .font(.system(size: 12))
                                .foregroundColor(appColors.secondaryText)
                            
                            Text(daysUntilPayment == 0 ? String(.today) : daysUntilPayment == 1 ? String(.tomorrow) : "\(daysUntilPayment)d")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(daysUntilPayment <= 3 ? appColors.destructive : appColors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    // Price
                    Text(dataManager.formattedCurrency(subscription.cost, currency: subscription.currency))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(appColors.primaryText)
                    
                    // Chevron for expansion
                    Image(systemName: showingActions ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(appColors.secondaryText)
                        .opacity(0.6)
                        .rotationEffect(.degrees(showingActions ? 0 : 0))
                        .animation(.easeInOut(duration: 0.2), value: showingActions)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable details and actions section
            if showingActions {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(appColors.border)
                        .frame(height: 0.5)
                        .opacity(0.3)
                    
                    // Subscription details
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("開始日期")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(appColors.secondaryText)
                                Text("\(subscription.nextPaymentDate, formatter: DateFormatter.shortDate)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(appColors.primaryText)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("計費週期")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(appColors.secondaryText)
                                Text(subscription.billingCycle.displayName)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(appColors.primaryText)
                            }
                        }
                        
                        if let description = subscription.description, !description.isEmpty {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("描述")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(appColors.secondaryText)
                                    Text(description)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(appColors.primaryText)
                                        .lineLimit(2)
                                }
                                Spacer()
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("月費換算")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(appColors.secondaryText)
                                Text(dataManager.formattedCurrency(subscription.monthlyCost))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(appColors.primaryText)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("年費換算")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(appColors.secondaryText)
                                Text(dataManager.formattedCurrency(subscription.monthlyCost * 12))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(appColors.primaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(appColors.secondaryBackground.opacity(0.5))
                    
                    Rectangle()
                        .fill(appColors.border)
                        .frame(height: 0.5)
                        .opacity(0.3)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            showingEditSubscription = true
                            showingActions = false
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                                Text(.edit)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(appColors.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(appColors.secondaryBackground)
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.system(size: 12))
                                Text(.delete)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(appColors.destructive)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(appColors.destructive.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(appColors.secondaryBackground.opacity(0.3))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: showingActions)
            }
        }
        .alert(String(.deleteConfirmTitle), isPresented: $showingDeleteAlert) {
            Button(String(.cancel), role: .cancel) { 
                showingActions = false 
            }
            Button(String(.delete), role: .destructive) {
                dataManager.deleteSubscription(subscription)
            }
        } message: {
            Text(String(.deleteConfirmMessage).replacingOccurrences(of: "%@", with: subscription.name))
        }
        .sheet(isPresented: $showingEditSubscription) {
            EditSubscriptionView(subscription: subscription)
                .environmentObject(dataManager)
                .environmentObject(LocalizationManager.shared)
        }
    }
}

#Preview {
    AllSubscriptionsView()
        .environmentObject(DataManager.shared)
}