import SwiftUI

struct BlackCardView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    
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
                // Black Card Visual
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 200)
                        .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("BLACK CARD")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("**** **** **** 0001")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text(gameState.currentPlayer.name.uppercased())
                                .font(.caption)
                                .foregroundColor(.white)
                            Spacer()
                            Text("VALID THRU 12/28")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // Card Details
                VStack(spacing: 15) {
                    InfoRow(title: "Current Balance", value: formatCurrency(gameState.blackCardBalance))
                    InfoRow(title: "Credit Limit", value: formatCurrency(1000000))
                    InfoRow(title: "Available Credit", value: formatCurrency(1000000 - gameState.blackCardBalance))
                    InfoRow(title: "Interest Rate", value: "1.0% APR")
                    InfoRow(title: "Payment Due", value: formatCurrency(gameState.blackCardBalance * 0.03))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Recent Transactions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if gameState.transactions.isEmpty {
                        Text("No recent transactions")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(gameState.transactions.prefix(5)) { transaction in
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
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Black Card")
    }
} 