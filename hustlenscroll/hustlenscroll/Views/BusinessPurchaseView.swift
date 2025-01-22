import SwiftUI

struct BusinessPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameState: GameState
    let opportunity: BusinessOpportunity
    
    private var canAffordWithBank: Bool {
        gameState.currentPlayer.bankBalance >= opportunity.setupCost
    }
    
    private var canAffordWithSavings: Bool {
        gameState.currentPlayer.savingsBalance >= opportunity.setupCost
    }
    
    private var canAffordWithCredit: Bool {
        (gameState.creditLimit - gameState.creditCardBalance) >= opportunity.setupCost
    }
    
    private var canAfford: Bool {
        canAffordWithBank || canAffordWithSavings || canAffordWithCredit
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
                        
                        Divider()
                        
                        InfoRow(title: "Monthly Revenue", value: "$\(Int(opportunity.monthlyRevenue))")
                        InfoRow(title: "Monthly Expenses", value: "$\(Int(opportunity.monthlyExpenses))")
                        InfoRow(title: "Monthly Profit", value: "$\(Int(opportunity.monthlyCashflow))")
                        InfoRow(title: "Required Investment", value: "$\(Int(opportunity.setupCost))")
                        InfoRow(title: "Revenue Share", value: "\(Int(opportunity.revenueShare))%")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Available Funds
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Funds")
                            .font(.headline)
                        
                        InfoRow(title: "Current Account", value: "$\(Int(gameState.currentPlayer.bankBalance))")
                        InfoRow(title: "Savings Account", value: "$\(Int(gameState.currentPlayer.savingsBalance))")
                        InfoRow(title: "Available Credit", value: "$\(Int(gameState.creditLimit - gameState.creditCardBalance))")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Decision Buttons
                    VStack(spacing: 15) {
                        if canAfford {
                            HStack(spacing: 15) {
                                Button {
                                    handleRejection()
                                } label: {
                                    Text("Reject")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                
                                Button {
                                    handlePurchase()
                                } label: {
                                    Text("Accept")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                        } else {
                            Button {
                                handleRejection()
                            } label: {
                                Text("Reject")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            
                            Text("Insufficient funds available")
                                .foregroundColor(.red)
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
    
    private func handlePurchase() {
        print("💼 Handling business purchase:")
        print("  - Business: \(opportunity.title)")
        print("  - Cost: $\(opportunity.setupCost)")
        
        // Add user's acceptance message
        let userMessage = Message(
            senderId: opportunity.source == .partner ? "broker" : "founder",
            senderName: gameState.currentPlayer.name,
            senderRole: gameState.currentPlayer.role,
            timestamp: Date(),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.userAcceptanceMessages),
            isRead: true
        )
        print("  - Adding user acceptance message")
        gameState.addMessageToThread(senderId: userMessage.senderId, message: userMessage)
        
        // Add broker's follow-up message
        let brokerMessage = Message(
            senderId: opportunity.source == .partner ? "broker" : "founder",
            senderName: opportunity.source == .partner ? "Alex Thompson" : "Mike Wilson",
            senderRole: opportunity.source == .partner ? "Business Broker" : "Founder",
            timestamp: Date().addingTimeInterval(30),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.brokerFollowUpMessages),
            isRead: false
        )
        print("  - Adding broker follow-up message")
        gameState.addMessageToThread(senderId: brokerMessage.senderId, message: brokerMessage)
        
        // Process the purchase
        print("  - Processing payment:")
        if canAffordWithBank {
            print("    Using bank account")
            gameState.currentPlayer.bankBalance -= opportunity.setupCost
        } else if canAffordWithSavings {
            print("    Using savings account")
            gameState.currentPlayer.savingsBalance -= opportunity.setupCost
        } else if canAffordWithCredit {
            print("    Using credit card")
            gameState.creditCardBalance += opportunity.setupCost
        }
        
        // Add the business
        print("  - Adding business to portfolio")
        gameState.acceptOpportunity(opportunity)
        
        // Add accountant's confirmation
        let accountantMessage = Message(
            senderId: "accountant",  // Use accountant's own thread
            senderName: "Steven Johnson",
            senderRole: "Accountant",
            timestamp: Date().addingTimeInterval(60),
            content: BusinessResponseMessages.getRandomMessage(
                BusinessResponseMessages.accountantConfirmations,
                replacements: ["company": opportunity.title]
            ),
            isRead: false
        )
        print("  - Adding accountant confirmation message")
        gameState.addMessageToThread(senderId: accountantMessage.senderId, message: accountantMessage)
        
        print("  - Purchase complete, dismissing view")
        dismiss()
    }
    
    private func handleRejection() {
        print("❌ Handling business rejection:")
        print("  - Business: \(opportunity.title)")
        
        // Add user's rejection message
        let userMessage = Message(
            senderId: opportunity.source == .partner ? "broker" : "founder",
            senderName: gameState.currentPlayer.name,
            senderRole: gameState.currentPlayer.role,
            timestamp: Date(),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.userRejectionMessages),
            isRead: true
        )
        print("  - Adding user rejection message")
        gameState.addMessageToThread(senderId: userMessage.senderId, message: userMessage)
        
        // Add broker's response
        let brokerMessage = Message(
            senderId: opportunity.source == .partner ? "broker" : "founder",
            senderName: opportunity.source == .partner ? "Alex Thompson" : "Mike Wilson",
            senderRole: opportunity.source == .partner ? "Business Broker" : "Founder",
            timestamp: Date().addingTimeInterval(30),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.brokerRejectionResponses),
            isRead: false
        )
        print("  - Adding broker response message")
        gameState.addMessageToThread(senderId: brokerMessage.senderId, message: brokerMessage)
        
        print("  - Rejection complete, dismissing view")
        dismiss()
    }
} 