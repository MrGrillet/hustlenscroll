import SwiftUI

struct BusinessPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameState: GameState
    let opportunity: BusinessOpportunity
    
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
    
    private var canAffordWithBank: Bool {
        gameState.currentPlayer.bankBalance >= opportunity.setupCost
    }
    
    private var canAffordWithSavings: Bool {
        gameState.currentPlayer.savingsBalance >= opportunity.setupCost
    }
    
    private var canAffordWithFamilyTrust: Bool {
        gameState.familyTrustBalance >= opportunity.setupCost
    }
    
    private var canAffordWithStandardCredit: Bool {
        (currentRole?.creditCardLimit ?? 5000) - gameState.creditCardBalance >= opportunity.setupCost
    }
    
    private var canAffordWithPlatinumCard: Bool {
        isPlatinumCardEligible && (100000 - gameState.platinumCardBalance >= opportunity.setupCost)
    }
    
    private var canAffordWithBlackCard: Bool {
        isBlackCardEligible && (1000000 - gameState.blackCardBalance >= opportunity.setupCost)
    }
    
    private var canAffordWithCredit: Bool {
        standardCardAvailableCredit >= opportunity.setupCost
    }
    
    private var canAfford: Bool {
        canAffordWithBank || canAffordWithSavings || canAffordWithStandardCredit || 
        canAffordWithPlatinumCard || canAffordWithBlackCard || canAffordWithFamilyTrust
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Business Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text(opportunity.title)
                            .font(.title2)
                            .bold()
                        
                        Text(opportunity.description)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Monthly Revenue", value: formatCurrency(opportunity.monthlyRevenue))
                            InfoRow(title: "Monthly Expenses", value: formatCurrency(opportunity.monthlyExpenses))
                            InfoRow(title: "Monthly Profit", value: formatCurrency(opportunity.monthlyCashflow))
                            InfoRow(title: "Setup Cost", value: formatCurrency(opportunity.setupCost))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Payment Options
                    if canAfford {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Payment Options")
                                .font(.headline)
                            
                            // Black Card (if eligible)
                            if isBlackCardEligible {
                                PaymentOptionRow(
                                    title: "Black Card",
                                    available: blackCardAvailableCredit,
                                    color: .black
                                )
                                .onTapGesture {
                                    handlePurchase(using: .blackCard)
                                }
                                .opacity(canAffordWithBlackCard ? 1 : 0.5)
                                .disabled(!canAffordWithBlackCard)
                            }

                            // Family Trust
                            PaymentOptionRow(
                                title: "Family Trust",
                                available: gameState.familyTrustBalance,
                                color: .purple
                            )
                            .onTapGesture {
                                handlePurchase(using: .familyTrust)
                            }
                            .opacity(canAffordWithFamilyTrust ? 1 : 0.5)
                            .disabled(!canAffordWithFamilyTrust)

                            // Platinum Card (if eligible)
                            if isPlatinumCardEligible {
                                PaymentOptionRow(
                                    title: "Platinum Card",
                                    available: platinumCardAvailableCredit,
                                    color: .gray
                                )
                                .onTapGesture {
                                    handlePurchase(using: .platinumCard)
                                }
                                .opacity(canAffordWithPlatinumCard ? 1 : 0.5)
                                .disabled(!canAffordWithPlatinumCard)
                            }

                            // Standard Credit Card
                            PaymentOptionRow(
                                title: "Credit Card",
                                available: standardCardAvailableCredit,
                                color: Color(uiColor: .systemGray5)
                            )
                            .onTapGesture {
                                handlePurchase(using: .credit)
                            }
                            .opacity(canAffordWithCredit ? 1 : 0.5)
                            .disabled(!canAffordWithCredit)

                            // Checking Account
                            PaymentOptionRow(
                                title: "Checking Account",
                                available: gameState.currentPlayer.bankBalance,
                                color: Color(uiColor: .systemGray5)
                            )
                            .onTapGesture {
                                handlePurchase(using: .bankAccount)
                            }
                            .opacity(canAffordWithBank ? 1 : 0.5)
                            .disabled(!canAffordWithBank)

                            // Savings Account
                            PaymentOptionRow(
                                title: "Savings Account",
                                available: gameState.currentPlayer.savingsBalance,
                                color: Color(uiColor: .systemGray5)
                            )
                            .onTapGesture {
                                handlePurchase(using: .savings)
                            }
                            .opacity(canAffordWithSavings ? 1 : 0.5)
                            .disabled(!canAffordWithSavings)

                            // Reject Button
                            Button(action: { dismiss() }) {
                                Text("Reject Opportunity")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .padding(.top)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Review Opportunity")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
    }
    
    private enum PaymentMethod {
        case bankAccount
        case savings
        case familyTrust
        case credit
        case platinumCard
        case blackCard
    }
    
    private func handlePurchase(using method: PaymentMethod) {
        print("\n💼 BUSINESS PURCHASE LOG:")
        print("----------------------------------------")
        print("Initial State:")
        print("  - Active Businesses Count: \(gameState.activeBusinesses.count)")
        print("  - Business to Purchase: \(opportunity.title)")
        print("  - Setup Cost: $\(opportunity.setupCost)")
        print("  - Monthly Revenue: $\(opportunity.monthlyRevenue)")
        print("  - Monthly Expenses: $\(opportunity.monthlyExpenses)")
        
        // Add user's acceptance message
        let userMessage = Message(
            senderId: opportunity.source == .partner ? "broker" : "founder",
            senderName: gameState.currentPlayer.name,
            senderRole: gameState.currentPlayer.role,
            timestamp: Date(),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.userAcceptanceMessages),
            isRead: true
        )
        print("\nAdding User Message:")
        print("  - Sender: \(userMessage.senderName)")
        print("  - Role: \(userMessage.senderRole)")
        gameState.addMessageToThread(senderId: userMessage.senderId, message: userMessage)
        
        // Process payment
        print("\nProcessing Payment:")
        switch method {
        case .bankAccount:
            print("  - Method: Bank Account")
            print("  - Previous Balance: $\(gameState.currentPlayer.bankBalance)")
            gameState.currentPlayer.bankBalance -= opportunity.setupCost
            print("  - New Balance: $\(gameState.currentPlayer.bankBalance)")
        case .savings:
            print("  - Method: Savings Account")
            print("  - Previous Balance: $\(gameState.currentPlayer.savingsBalance)")
            gameState.currentPlayer.savingsBalance -= opportunity.setupCost
            print("  - New Balance: $\(gameState.currentPlayer.savingsBalance)")
        case .familyTrust:
            print("  - Method: Family Trust")
            print("  - Previous Balance: $\(gameState.familyTrustBalance)")
            gameState.familyTrustBalance -= opportunity.setupCost
            print("  - New Balance: $\(gameState.familyTrustBalance)")
        case .credit:
            print("  - Method: Credit Card")
            print("  - Previous Balance: $\(gameState.creditCardBalance)")
            gameState.creditCardBalance += opportunity.setupCost
            print("  - New Balance: $\(gameState.creditCardBalance)")
        case .platinumCard:
            print("  - Method: Platinum Card")
            print("  - Previous Balance: $\(gameState.platinumCardBalance)")
            gameState.platinumCardBalance += opportunity.setupCost
            print("  - New Balance: $\(gameState.platinumCardBalance)")
        case .blackCard:
            print("  - Method: Black Card")
            print("  - Previous Balance: $\(gameState.blackCardBalance)")
            gameState.blackCardBalance += opportunity.setupCost
            print("  - New Balance: $\(gameState.blackCardBalance)")
        }
        
        // Add the business
        print("\nAdding Business to Portfolio:")
        print("  - Active Businesses Before: \(gameState.activeBusinesses.count)")
        gameState.acceptOpportunity(opportunity)
        print("  - Active Businesses After: \(gameState.activeBusinesses.count)")
        print("  - Business Added Successfully: \(gameState.activeBusinesses.contains { $0.title == opportunity.title })")
        
        // Add accountant's confirmation
        let accountantMessage = Message(
            senderId: "accountant",
            senderName: "Steven Johnson",
            senderRole: "Accountant",
            timestamp: Date().addingTimeInterval(60),
            content: BusinessResponseMessages.getRandomMessage(
                BusinessResponseMessages.accountantConfirmations,
                replacements: ["company": opportunity.title]
            ),
            isRead: false
        )
        print("\nAdding Accountant Confirmation:")
        print("  - Message: \(accountantMessage.content)")
        gameState.addMessageToThread(senderId: accountantMessage.senderId, message: accountantMessage)
        
        // Save state and update UI
        print("\nSaving State and Updating UI:")
        print("  - Saving game state...")
        gameState.saveState()
        print("  - Notifying UI of changes...")
        gameState.objectWillChange.send()
        
        // Force UI refresh
        DispatchQueue.main.async {
            gameState.objectWillChange.send()
        }
        
        print("\nFinal State Check:")
        print("  - Active Businesses Count: \(gameState.activeBusinesses.count)")
        print("  - Business Present: \(gameState.activeBusinesses.contains { $0.title == opportunity.title })")
        print("----------------------------------------")
        
        print("Purchase complete, dismissing view")
        dismiss()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

struct PaymentOptionRow: View {
    let title: String
    let available: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(formatCurrency(available))
                .font(.subheadline)
        }
        .foregroundColor(color == .black ? .white : .primary)
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(color == .black ? 1 : 0.1))
        .cornerRadius(10)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
} 