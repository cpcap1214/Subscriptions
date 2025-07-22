//
//  AddSubscriptionView.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct AddSubscriptionView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appColors) var appColors
    
    @State private var name = ""
    @State private var cost = ""
    @State private var selectedCurrency = Currency.usd
    @State private var selectedBillingCycle = BillingCycle.monthly
    @State private var selectedCategory = SubscriptionCategory.entertainment
    @State private var firstPaymentDate = Date()
    @State private var autoCalculateNextPayment = true
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isCostFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text(.addNewSubscription)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(appColors.primaryText)
                        
                        Text(.trackYourServices)
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
                                        .foregroundColor(.gray)
                                    
                                    TextField("0.00", text: $cost)
                                        .font(.system(size: 16, weight: .regular))
                                        .keyboardType(.decimalPad)
                                        .focused($isCostFieldFocused)
                                        .toolbar {
                                            ToolbarItemGroup(placement: .keyboard) {
                                                Spacer()
                                                Button(String(.done)) {
                                                    isCostFieldFocused = false
                                                }
                                            }
                                        }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
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
                                            HStack(spacing: 12) {
                                                // 貨幣符號
                                                Text(currency.symbol)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.primary)
                                                    .frame(width: 32, alignment: .leading)
                                                
                                                // 貨幣信息
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(currency.displayName)
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(currency.rawValue)
                                                        .font(.system(size: 13, weight: .regular))
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                if currency == selectedCurrency {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedCurrency.symbol)
                                            .font(.system(size: 14, weight: .semibold))
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 10))
                                            .foregroundColor(appColors.secondaryText)
                                    }
                                    .foregroundColor(appColors.primaryText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
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
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Auto-calculate Next Payment Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(.autoCalculateNextPayment)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(appColors.primaryText)
                                    
                                    Text(.autoCalculateNextPaymentDescription)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(appColors.secondaryText)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $autoCalculateNextPayment)
                                    .toggleStyle(SwitchToggleStyle())
                            }
                        }
                        
                        // First Payment Date (only show if auto-calculate is off)
                        if !autoCalculateNextPayment {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(.firstPaymentDate)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(appColors.primaryText)
                                
                                DatePicker("", selection: $firstPaymentDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
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
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            saveSubscription()
                        }) {
                            Text(.addSubscription)
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
                Button(String(.ok)) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            selectedCurrency = dataManager.preferredCurrency
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !cost.isEmpty && Double(cost) != nil && Double(cost)! > 0
    }
    
    private func saveSubscription() {
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
        
        // Calculate next payment date
        let nextPaymentDate: Date
        if autoCalculateNextPayment {
            // Calculate next payment date based on billing cycle from today
            let today = Date()
            var components = DateComponents()
            
            switch selectedBillingCycle {
            case .weekly:
                components.weekOfYear = 1
            case .monthly:
                components.month = 1
            case .quarterly:
                components.month = 3
            case .semiAnnually:
                components.month = 6
            case .annually:
                components.year = 1
            }
            
            nextPaymentDate = Calendar.current.date(byAdding: components, to: today) ?? today
        } else {
            nextPaymentDate = firstPaymentDate
        }
        
        let subscription = Subscription(
            name: name,
            cost: costValue,
            currency: selectedCurrency.rawValue,
            billingCycle: selectedBillingCycle,
            nextPaymentDate: nextPaymentDate,
            category: selectedCategory
        )
        
        dataManager.addSubscription(subscription)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddSubscriptionView()
        .environmentObject(DataManager.shared)
}