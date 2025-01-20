import SwiftUI

struct InvestmentPurchaseView: View {
    let asset: Asset
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) var dismiss
    @State private var quantity: Double = 1
    @State private var showingPaymentOptions = false
    @State private var selectedPaymentMethod: PaymentMethod = .bankAccount
    
    enum PaymentMethod {
        case bankAccount
        case savings
        case credit
    }
    
    var totalCost: Double {
        quantity * asset.currentPrice
    }
    
    var canAffordWithBank: Bool {
        totalCost <= gameState.currentPlayer.bankBalance
    }
    
    var canAffordWithSavings: Bool {
        totalCost <= gameState.currentPlayer.savingsBalance
    }
    
    var canAffordWithCredit: Bool {
        totalCost <= (gameState.creditLimit - gameState.creditCardBalance)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Asset Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(asset.name)
                            .font(.title2)
                            .bold()
                        Text(asset.symbol)
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Current Price: \(asset.currentPrice, format: .currency(code: "USD"))")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Quantity Selection
                    VStack(spacing: 12) {
                        Text("Quantity")
                            .font(.headline)
                        
                        HStack {
                            Button { if quantity > 1 { quantity -= 1 } } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                            }
                            
                            TextField("Quantity", value: $quantity, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(width: 100)
                                .keyboardType(.decimalPad)
                            
                            Button { quantity += 1 } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                    
                    // Total Cost
                    VStack(spacing: 8) {
                        Text("Total Cost")
                            .font(.headline)
                        Text(totalCost, format: .currency(code: "USD"))
                            .font(.title)
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Available Funds
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Funds:")
                            .font(.headline)
                        Text("Bank Account: \(gameState.currentPlayer.bankBalance, format: .currency(code: "USD"))")
                        Text("Savings: \(gameState.currentPlayer.savingsBalance, format: .currency(code: "USD"))")
                        Text("Credit Available: \((gameState.creditLimit - gameState.creditCardBalance), format: .currency(code: "USD"))")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    if canAffordWithBank {
                        // Simple Buy Button
                        Button {
                            executePurchase()
                            dismiss()
                        } label: {
                            Text("Buy Now")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    } else if canAffordWithSavings || canAffordWithCredit {
                        // Payment Options Button
                        Button {
                            showingPaymentOptions = true
                        } label: {
                            Text("Select Payment Method")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    } else {
                        // Insufficient Funds Message
                        Text("Insufficient funds available")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Buy \(asset.symbol)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .actionSheet(isPresented: $showingPaymentOptions) {
                var buttons: [ActionSheet.Button] = []
                
                if canAffordWithSavings {
                    buttons.append(.default(Text("Use Savings")) {
                        selectedPaymentMethod = .savings
                        executePurchase()
                        dismiss()
                    })
                }
                
                if canAffordWithCredit {
                    buttons.append(.default(Text("Use Credit Card")) {
                        selectedPaymentMethod = .credit
                        executePurchase()
                        dismiss()
                    })
                }
                
                buttons.append(.cancel())
                
                return ActionSheet(
                    title: Text("Select Payment Method"),
                    message: Text("Choose how you want to pay for this investment"),
                    buttons: buttons
                )
            }
        }
    }
    
    private func executePurchase() {
        switch selectedPaymentMethod {
        case .bankAccount:
            if asset.type == .crypto {
                gameState.buyCrypto(symbol: asset.symbol, name: asset.name, quantity: quantity, price: asset.currentPrice)
            } else {
                gameState.buyStock(symbol: asset.symbol, name: asset.name, quantity: quantity, price: asset.currentPrice)
            }
        case .savings:
            // Transfer from savings first
            gameState.transferFromSavings(amount: totalCost)
            if asset.type == .crypto {
                gameState.buyCrypto(symbol: asset.symbol, name: asset.name, quantity: quantity, price: asset.currentPrice)
            } else {
                gameState.buyStock(symbol: asset.symbol, name: asset.name, quantity: quantity, price: asset.currentPrice)
            }
        case .credit:
            // Use credit card
            gameState.useCredit(amount: totalCost)
            if asset.type == .crypto {
                gameState.buyCrypto(symbol: asset.symbol, name: asset.name, quantity: quantity, price: asset.currentPrice)
            } else {
                gameState.buyStock(symbol: asset.symbol, name: asset.name, quantity: quantity, price: asset.currentPrice)
            }
        }
    }
} 