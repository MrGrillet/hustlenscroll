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
                                    handleAcceptance()
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
    
    private func handleAcceptance() {
        // Add user's acceptance message
        let userMessage = Message(
            senderId: "USER",
            senderName: gameState.currentPlayer.name,
            senderRole: gameState.currentPlayer.role,
            timestamp: Date(),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.userAcceptanceMessages),
            isRead: true
        )
        gameState.messages.append(userMessage)
        
        // Add broker's follow-up message
        let brokerMessage = Message(
            senderId: opportunity.source == .partner ? "broker" : "founder",
            senderName: opportunity.source == .partner ? "Alex Thompson" : "Mike Wilson",
            senderRole: opportunity.source == .partner ? "Business Broker" : "Founder",
            timestamp: Date().addingTimeInterval(30),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.brokerFollowUpMessages),
            isRead: false
        )
        gameState.messages.append(brokerMessage)
        
        // Process the purchase
        if canAffordWithBank {
            gameState.currentPlayer.bankBalance -= opportunity.setupCost
        } else if canAffordWithSavings {
            gameState.currentPlayer.savingsBalance -= opportunity.setupCost
        } else if canAffordWithCredit {
            gameState.creditCardBalance += opportunity.setupCost
        }
        
        // Add the business
        gameState.acceptOpportunity(opportunity)
        
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
        gameState.messages.append(accountantMessage)
        
        gameState.objectWillChange.send()
        gameState.saveState()
        dismiss()
    }
    
    private func handleRejection() {
        // Add user's rejection message
        let userMessage = Message(
            senderId: "USER",
            senderName: gameState.currentPlayer.name,
            senderRole: gameState.currentPlayer.role,
            timestamp: Date(),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.userRejectionMessages),
            isRead: true
        )
        gameState.messages.append(userMessage)
        
        // Add broker's response
        let brokerMessage = Message(
            senderId: opportunity.source == .partner ? "broker" : "founder",
            senderName: opportunity.source == .partner ? "Alex Thompson" : "Mike Wilson",
            senderRole: opportunity.source == .partner ? "Business Broker" : "Founder",
            timestamp: Date().addingTimeInterval(30),
            content: BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.brokerRejectionResponses),
            isRead: false
        )
        gameState.messages.append(brokerMessage)
        
        gameState.objectWillChange.send()
        gameState.saveState()
        dismiss()
    }
} 