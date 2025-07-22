//
//  EditSubscriptionView.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct EditSubscriptionView: View {
    let subscription: Subscription
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appColors) var appColors
    
    @State private var name: String
    @State private var cost: String
    @State private var selectedCurrency: Currency
    @State private var selectedBillingCycle: BillingCycle
    @State private var selectedCategory: SubscriptionCategory
    @State private var firstPaymentDate: Date
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isCostFieldFocused: Bool
    
    init(subscription: Subscription) {
        self.subscription = subscription
        self._name = State(initialValue: subscription.name)
        self._cost = State(initialValue: String(format: "%.2f", subscription.cost))
        self._selectedCurrency = State(initialValue: Currency(rawValue: subscription.currency) ?? .usd)
        self._selectedBillingCycle = State(initialValue: subscription.billingCycle)
        self._selectedCategory = State(initialValue: subscription.category)
        self._firstPaymentDate = State(initialValue: subscription.nextPaymentDate)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("編輯訂閱")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(appColors.primaryText)
                        
                        Text("更新您的服務資訊")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(appColors.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 24) {
                        // Service Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text(.serviceName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                            
                            TextField(String(.serviceNamePlaceholder), text: $name)
                                .font(.system(size: 16, weight: .regular))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(appColors.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(name.isEmpty ? Color.clear : appColors.accent, lineWidth: 1)
                                )
                                .focused($isNameFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    isNameFieldFocused = false
                                }
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text(.amount)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                            
                            HStack(spacing: 12) {
                                HStack {
                                    Text(selectedCurrency.symbol)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(appColors.secondaryText)
                                    
                                    TextField("0.00", text: $cost)
                                        .font(.system(size: 16, weight: .regular))
                                        .keyboardType(.decimalPad)
                                        .focused($isCostFieldFocused)
                                        .toolbar {
                                            ToolbarItemGroup(placement: .keyboard) {
                                                Spacer()
                                                Button("完成") {
                                                    isCostFieldFocused = false
                                                }
                                            }
                                        }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(appColors.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(cost.isEmpty ? Color.clear : appColors.accent, lineWidth: 1)
                                )
                                
                                Menu {
                                    ForEach(Currency.allCases, id: \.self) { currency in
                                        Button(action: {
                                            selectedCurrency = currency
                                        }) {
                                            HStack {
                                                Text(currency.symbol)
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text(currency.displayName)
                                                    .font(.system(size: 14, weight: .regular))
                                                if currency == selectedCurrency {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Text("\(selectedCurrency.symbol) \(selectedCurrency.displayName)")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(appColors.primaryText)
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
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text(.category)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                            
                            Menu {
                                ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        HStack {
                                            Image(systemName: category.iconName)
                                            Text(category.displayName)
                                            if category == selectedCategory {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: selectedCategory.iconName)
                                        .foregroundColor(appColors.primaryText)
                                        .frame(width: 20)
                                    
                                    Text(selectedCategory.displayName)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(appColors.primaryText)
                                    
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
                        
                        // Next Payment Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("下次付款日期")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                            
                            DatePicker("", selection: $firstPaymentDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(appColors.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(appColors.border, lineWidth: 1)
                                )
                        }
                        
                        // Billing Cycle
                        VStack(alignment: .leading, spacing: 8) {
                            Text(.billingCycle)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                            
                            Menu {
                                ForEach(BillingCycle.allCases, id: \.self) { cycle in
                                    Button(action: {
                                        selectedBillingCycle = cycle
                                    }) {
                                        HStack {
                                            Text(cycle.displayName)
                                            if cycle == selectedBillingCycle {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedBillingCycle.displayName)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(appColors.primaryText)
                                    
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
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            updateSubscription()
                        }) {
                            Text("更新訂閱")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(appColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isFormValid ? appColors.accent : appColors.secondaryText)
                                .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(.cancel)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(appColors.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(appColors.secondaryBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .background(appColors.background)
            .navigationBarHidden(true)
            .alert(String(.errorTitle), isPresented: $showingError) {
                Button("確定") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !cost.isEmpty && Double(cost) != nil && Double(cost)! > 0
    }
    
    private func updateSubscription() {
        guard !name.isEmpty else {
            errorMessage = String(.enterServiceName)
            showingError = true
            return
        }
        
        guard let costValue = Double(cost), costValue > 0 else {
            errorMessage = String(.enterValidAmount)
            showingError = true
            return
        }
        
        let updatedSubscription = Subscription(
            id: subscription.id,
            name: name,
            cost: costValue,
            currency: selectedCurrency.rawValue,
            billingCycle: selectedBillingCycle,
            nextPaymentDate: firstPaymentDate,
            category: selectedCategory,
            isActive: subscription.isActive
        )
        
        dataManager.updateSubscription(updatedSubscription)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    EditSubscriptionView(subscription: Subscription.sampleData[0])
        .environmentObject(DataManager.shared)
        .environmentObject(LocalizationManager.shared)
}