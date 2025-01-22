import SwiftUI

struct FamilyTrustView: View {
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
                // Trust Overview
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Trust Balance")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(formatCurrency(gameState.familyTrustBalance))
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                    }
                    
                    Divider()
                    
                    // Trust Details
                    InfoRow(title: "Annual Return", value: "6.0%")
                    InfoRow(title: "Trust Type", value: "Family Wealth Management")
                    InfoRow(title: "Status", value: "Active")
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Trust Information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Trust Features")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Wealth Growth", description: "Compound interest with monthly returns")
                        FeatureRow(icon: "shield.fill", title: "Asset Protection", description: "Protected from personal liabilities")
                        FeatureRow(icon: "leaf.fill", title: "Tax Efficiency", description: "Optimized for tax advantages")
                        FeatureRow(icon: "person.3.fill", title: "Family Benefits", description: "Structured for generational wealth transfer")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
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
        .navigationTitle("Family Trust")
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