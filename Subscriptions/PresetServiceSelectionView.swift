//
//  PresetServiceSelectionView.swift
//  Subscriptions
//
//  Created by 鍾心哲 on 2025/7/22.
//

import SwiftUI

struct PresetServiceSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.appColors) var appColors
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    let selectedService: (PresetService) -> Void
    
    private var filteredServices: [PresetService] {
        if searchText.isEmpty {
            return PresetService.allServices
        } else {
            return PresetService.searchServices(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
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
                        
                        Text("選擇訂閱服務")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(appColors.primaryText)
                        
                        Spacer()
                        
                        // Custom service button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("自訂")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(appColors.accent)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Search bar
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("搜尋服務名稱...", text: $searchText)
                            .font(.system(size: 16, weight: .regular))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(appColors.secondaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                HStack {
                                    Spacer()
                                    if !searchText.isEmpty {
                                        Button(action: {
                                            searchText = ""
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(appColors.secondaryText)
                                        }
                                        .padding(.trailing, 16)
                                    }
                                }
                            )
                            .focused($isSearchFieldFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                isSearchFieldFocused = false
                            }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)
                
                // Services List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredServices.enumerated()), id: \.element.name) { index, service in
                            PresetServiceRowView(
                                service: service,
                                onTap: {
                                    selectedService(service)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                            
                            // Divider (except for last item)
                            if index < filteredServices.count - 1 {
                                Rectangle()
                                    .fill(appColors.border)
                                    .frame(height: 0.5)
                                    .opacity(0.3)
                                    .padding(.leading, 60)
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
                    
                    // Empty state
                    if filteredServices.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32))
                                .foregroundColor(appColors.secondaryText)
                                .opacity(0.4)
                            
                            Text("找不到相關服務")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(appColors.primaryText)
                            
                            Text("請嘗試其他關鍵字或點擊右上角「自訂」")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(appColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 40)
                    }
                }
            }
            .background(appColors.background)
            .navigationBarHidden(true)
        }
    }
}

struct PresetServiceRowView: View {
    let service: PresetService
    let onTap: () -> Void
    @Environment(\.appColors) var appColors
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Service icon
                Image(systemName: service.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(appColors.primaryText)
                    .frame(width: 32, height: 32)
                    .background(appColors.secondaryBackground)
                    .clipShape(Circle())
                
                // Service info
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(appColors.primaryText)
                    
                    HStack(spacing: 8) {
                        Text(service.description)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(appColors.secondaryText)
                        
                        Spacer()
                        
                        Text(formatCurrency(service.defaultCost, currency: service.defaultCurrency))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(appColors.secondaryText)
                    }
                }
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(appColors.secondaryText)
                    .opacity(0.6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let currencyEnum = Currency(rawValue: currency) ?? .usd
        return "\(currencyEnum.symbol)\(String(format: "%.2f", amount))"
    }
}

#Preview {
    PresetServiceSelectionView { service in
        print("Selected: \(service.name)")
    }
    .environmentObject(LocalizationManager.shared)
    .themed()
}