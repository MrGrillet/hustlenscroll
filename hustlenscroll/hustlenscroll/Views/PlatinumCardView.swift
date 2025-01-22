import SwiftUI

struct PlatinumCardView: View {
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
                // Platinum Card Visual
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.white.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 200)
                        .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("PLATINUM CARD")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "creditcard.fill")
                        }
                        
                        Spacer()
                        
                        Text("**** **** **** 0002")
                            .font(.title3)
                        
                        HStack {
                            Text(gameState.currentPlayer.name.uppercased())
                                .font(.caption)
                            Spacer()
                            Text("VALID THRU 12/28")
                                .font(.caption)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // Card Details
                VStack(spacing: 15) {
                    InfoRow(title: "Current Balance", value: formatCurrency(gameState.platinumCardBalance))
                    InfoRow(title: "Credit Limit", value: formatCurrency(100000))
                    InfoRow(title: "Available Credit", value: formatCurrency(100000 - gameState.platinumCardBalance))
                    InfoRow(title: "Interest Rate", value: "8.0% APR")
                    InfoRow(title: "Payment Due", value: formatCurrency(gameState.platinumCardBalance * 0.03))
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
        .navigationTitle("Platinum Card")
    }
} 