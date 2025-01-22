import SwiftUI

struct FamilyTrustView: View {
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
                // Trust Info
                VStack(alignment: .leading, spacing: 15) {
                    Text("Family Trust")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your family trust is a high-yield savings account that earns 6% annual interest. This account can be used for large purchases and investments.")
                            .font(.body)
                        
                        Text("Benefits:")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 5)
                        
                        Text("• 6% Annual Interest Rate\n• No withdrawal limits\n• Perfect for long-term savings")
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Current Status
                VStack(alignment: .leading, spacing: 15) {
                    Text("Current Status")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(title: "Current Balance", value: formatCurrency(gameState.familyTrustBalance))
                        InfoRow(title: "Monthly Interest", value: formatCurrency(gameState.familyTrustBalance * 0.005))
                        InfoRow(title: "Annual Return", value: "6.0%")
                        
                        Button(action: {
                            showingTransferSheet = true
                        }) {
                            Text("Transfer Money")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
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
                        $0.description.contains("Trust")
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
        .navigationTitle("Family Trust")
        .sheet(isPresented: $showingTransferSheet) {
            TransferView(fromAccountType: .familyTrust)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
} 