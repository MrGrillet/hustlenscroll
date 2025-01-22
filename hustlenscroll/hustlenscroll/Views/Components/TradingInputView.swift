import SwiftUI

struct TradingInputView: View {
    @Binding var quantity: Double
    let assetUpdate: MarketUpdate.Update
    let holdings: (quantity: Double, purchasePrice: Double)?
    let onSell: () -> Void
    @EnvironmentObject var gameState: GameState
    
    private var currentRole: Role? {
        Role.getRole(byTitle: gameState.currentPlayer.role)
    }
    
    private var isBlackCardEligible: Bool {
        currentRole?.creditCardLimit == 1000000
    }
    
    private var isPlatinumCardEligible: Bool {
        let limit = currentRole?.creditCardLimit ?? 0
        return limit >= 100000
    }
    
    private var totalCost: Double {
        quantity * assetUpdate.newPrice
    }
    
    private var standardCardAvailableCredit: Double {
        (currentRole?.creditCardLimit ?? 5000) - gameState.creditCardBalance
    }
    
    private var platinumCardAvailableCredit: Double {
        100000 - gameState.platinumCardBalance
    }
    
    private var blackCardAvailableCredit: Double {
        1000000 - gameState.blackCardBalance
    }
    
    private var familyTrustAvailable: Double {
        gameState.familyTrustBalance
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quantity Selector
            VStack(alignment: .leading, spacing: 10) {
                Text("Quantity")
                    .font(.headline)
                
                HStack {
                    Button(action: { quantity = max(0, quantity - 1) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    TextField("0.0", value: $quantity, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    
                    Spacer()
                    
                    Button(action: { quantity += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity)
                
                if quantity > 0 {
                    Text("Total Value: \(totalCost, format: .currency(code: "USD"))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Payment Options Section
            if quantity > 0 {
                Text("Payment Options")
                    .font(.headline)
                    .padding(.top)
                
                VStack(spacing: 10) {
                    // Black Card Button (if eligible)
                    if isBlackCardEligible {
                        PaymentOptionRow(
                            title: "Black Card",
                            available: blackCardAvailableCredit,
                            color: .black
                        )
                        .onTapGesture {
                            buyWithBlackCard()
                        }
                        .opacity(blackCardAvailableCredit >= totalCost ? 1 : 0.5)
                        .disabled(blackCardAvailableCredit < totalCost)
                    }
                    
                    // Family Trust Button
                    PaymentOptionRow(
                        title: "Family Trust",
                        available: familyTrustAvailable,
                        color: .purple
                    )
                    .onTapGesture {
                        buyWithFamilyTrust()
                    }
                    .opacity(familyTrustAvailable >= totalCost ? 1 : 0.5)
                    .disabled(familyTrustAvailable < totalCost)
                    
                    // Platinum Card Button (if eligible)
                    if isPlatinumCardEligible {
                        PaymentOptionRow(
                            title: "Platinum Card",
                            available: platinumCardAvailableCredit,
                            color: .gray
                        )
                        .onTapGesture {
                            buyWithPlatinumCard()
                        }
                        .opacity(platinumCardAvailableCredit >= totalCost ? 1 : 0.5)
                        .disabled(platinumCardAvailableCredit < totalCost)
                    }
                    
                    // Standard Credit Card Button
                    PaymentOptionRow(
                        title: "Credit Card",
                        available: standardCardAvailableCredit,
                        color: Color(uiColor: .systemGray5)
                    )
                    .onTapGesture {
                        buyWithCredit()
                    }
                    .opacity(standardCardAvailableCredit >= totalCost ? 1 : 0.5)
                    .disabled(standardCardAvailableCredit < totalCost)
                    
                    // Checking Account Button
                    PaymentOptionRow(
                        title: "Checking Account",
                        available: gameState.currentPlayer.bankBalance,
                        color: Color(uiColor: .systemGray5)
                    )
                    .onTapGesture {
                        buyWithCash()
                    }
                    .opacity(gameState.currentPlayer.bankBalance >= totalCost ? 1 : 0.5)
                    .disabled(gameState.currentPlayer.bankBalance < totalCost)
                    
                    // Savings Account Button
                    PaymentOptionRow(
                        title: "Savings Account",
                        available: gameState.currentPlayer.savingsBalance,
                        color: Color(uiColor: .systemGray5)
                    )
                    .onTapGesture {
                        buyWithSavings()
                    }
                    .opacity(gameState.currentPlayer.savingsBalance >= totalCost ? 1 : 0.5)
                    .disabled(gameState.currentPlayer.savingsBalance < totalCost)
                    
                    // Sell Button
                    Button(action: onSell) {
                        Text("Sell")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(holdings != nil && quantity <= (holdings?.quantity ?? 0) ? Color.red : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(holdings == nil || quantity > (holdings?.quantity ?? 0))
                    .padding(.top)
                }
            }
        }
        .padding()
    }
    
    private func buyWithCash() {
        guard gameState.currentPlayer.bankBalance >= totalCost else { return }
        gameState.currentPlayer.bankBalance -= totalCost
        processPurchase()
    }
    
    private func buyWithFamilyTrust() {
        guard familyTrustAvailable >= totalCost else { return }
        gameState.familyTrustBalance -= totalCost
        processPurchase()
    }
    
    private func buyWithSavings() {
        guard gameState.currentPlayer.savingsBalance >= totalCost else { return }
        gameState.currentPlayer.savingsBalance -= totalCost
        processPurchase()
    }
    
    private func buyWithBlackCard() {
        guard blackCardAvailableCredit >= totalCost else { return }
        gameState.blackCardBalance += totalCost
        processPurchase()
    }
    
    private func buyWithPlatinumCard() {
        guard platinumCardAvailableCredit >= totalCost else { return }
        gameState.platinumCardBalance += totalCost
        processPurchase()
    }
    
    private func buyWithCredit() {
        guard standardCardAvailableCredit >= totalCost else { return }
        gameState.creditCardBalance += totalCost
        processPurchase()
    }
    
    private func processPurchase() {
        if assetUpdate.type == .crypto {
            gameState.buyCrypto(
                symbol: assetUpdate.symbol,
                name: getAssetName(for: assetUpdate.symbol),
                quantity: quantity,
                price: assetUpdate.newPrice
            )
        } else {
            gameState.buyStock(
                symbol: assetUpdate.symbol,
                name: getAssetName(for: assetUpdate.symbol),
                quantity: quantity,
                price: assetUpdate.newPrice
            )
        }
        
        // Record transaction
        gameState.transactions.append(Transaction(
            date: Date(),
            description: "Buy \(quantity) \(assetUpdate.symbol)",
            amount: -totalCost,
            isIncome: false
        ))
        
        // Reset quantity
        quantity = 0
        
        // Save state
        gameState.saveState()
    }
    
    private func getAssetName(for symbol: String) -> String {
        switch symbol {
        case "BTC": return "Bitcoin"
        case "ETH": return "Ethereum"
        case "SOL": return "Solana"
        case "DOGE": return "Dogecoin"
        default: return symbol
        }
    }
} 