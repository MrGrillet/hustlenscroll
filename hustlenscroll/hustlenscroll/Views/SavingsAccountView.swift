import SwiftUI

struct SavingsAccountView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showingTransferSheet = false
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private func formatCurrency(_ value: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Savings Info
                VStack(alignment: .leading, spacing: 15) {
                    Text("Quantum Savings")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your savings account is a reserve of money that can be transferred to your checking account when needed. This money can be used to fund opportunities when your checking account balance is insufficient.")
                            .font(.body)
                        
                        Text("Example:")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 5)
                        
                        Text("If a business opportunity costs $50,000 but you only have $30,000 in your checking account, you can transfer money from your savings to cover the difference.")
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Current Status
                VStack(alignment: .leading, spacing: 15) {
                    Text("Current Status")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(title: "Current Balance", value: formatCurrency(gameState.currentPlayer.savingsBalance))
                        InfoRow(title: "Checking Account", value: formatCurrency(gameState.currentPlayer.bankBalance))
                        
                        Button(action: {
                            showingTransferSheet = true
                        }) {
                            Text("Transfer Money")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Transaction History
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    ForEach(gameState.transactions.filter { 
                        $0.description.contains("Savings")
                    }.prefix(10)) { transaction in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transaction.description)
                                    .font(.subheadline)
                                Text(transaction.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(formatCurrency(transaction.amount))
                                .foregroundColor(transaction.isIncome ? .green : .red)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Savings Account")
        .sheet(isPresented: $showingTransferSheet) {
            TransferView(fromAccountType: .savings)
        }
    }
} 