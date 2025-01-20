import SwiftUI

struct CreditCardView: View {
    @EnvironmentObject var gameState: GameState
    
    var monthlyInterestPayment: Double {
        gameState.creditCardBalance * 0.10
    }
    
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
                // Credit Card Info
                VStack(alignment: .leading, spacing: 15) {
                    Text("Quantum Credit Card")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This credit card allows you to borrow money at 10% monthly interest. The interest payment will be added to your monthly expenses until the debt is paid off.")
                            .font(.body)
                        
                        Text("Example:")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 5)
                        
                        Text("If you borrow $10,000, you'll pay $1,000 in interest each month until you pay off the balance.")
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
                        InfoRow(title: "Current Balance", value: formatCurrency(gameState.creditCardBalance))
                        InfoRow(title: "Credit Limit", value: formatCurrency(gameState.creditLimit))
                        InfoRow(title: "Available Credit", value: formatCurrency(gameState.creditLimit - gameState.creditCardBalance))
                        
                        if gameState.creditCardBalance > 0 {
                            Divider()
                                .padding(.vertical, 5)
                            
                            InfoRow(title: "Monthly Interest (10%)", value: formatCurrency(monthlyInterestPayment))
                                .foregroundColor(.red)
                        }
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
                    
                    ForEach(gameState.transactions.filter { $0.description.contains("Credit") }.prefix(10)) { transaction in
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
        .navigationTitle("Credit Card")
    }
} 