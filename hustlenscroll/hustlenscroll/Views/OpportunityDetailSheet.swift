import SwiftUI

struct OpportunityDetailSheet: View {
    let opportunity: BusinessOpportunity
    let post: Post
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Author Info
                    HStack {
                        VStack(alignment: .leading) {
                            Text(post.author)
                                .font(.headline)
                            Text(post.role)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.bottom)
                    
                    // Opportunity Details
                    Group {
                        Text(opportunity.title)
                            .font(.title2)
                            .bold()
                        
                        Text(opportunity.description)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(title: "Monthly Revenue", value: "$\(Int(opportunity.monthlyRevenue))")
                            InfoRow(title: "Monthly Expenses", value: "$\(Int(opportunity.monthlyExpenses))")
                            InfoRow(title: "Monthly Profit", value: "$\(Int(opportunity.monthlyCashflow))")
                            if opportunity.setupCost > 0 {
                                InfoRow(title: "Initial Investment", value: "$\(Int(opportunity.setupCost))")
                            }
                            InfoRow(title: "Potential Multiple", value: "\(String(format: "%.1fx", opportunity.potentialSaleMultiple))")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if gameState.currentPlayer.bankBalance < opportunity.setupCost {
                            Text("Insufficient funds - you need $\(Int(opportunity.setupCost).formattedWithSeparator)")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.bottom, 4)
                        }
                        
                        Button(action: {
                            gameState.acceptOpportunity(opportunity)
                            dismiss()
                        }) {
                            Text("Accept Opportunity")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(gameState.currentPlayer.bankBalance >= opportunity.setupCost ? Color.blue : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(gameState.currentPlayer.bankBalance < opportunity.setupCost)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Decline")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
} 