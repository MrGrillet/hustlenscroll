import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var gameState: GameState
    let accountType: AccountType
    
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
                // Account Overview
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Current Balance")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(formatCurrency(accountBalance))
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                        Image(systemName: accountIcon)
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    
                    if accountType == .checking {
                        Divider()
                        
                        InfoRow(title: "Monthly Income", value: formatCurrency(gameState.monthlyIncome))
                        InfoRow(title: "Monthly Expenses", value: formatCurrency(gameState.monthlyExpenses))
                        InfoRow(title: "Net Cash Flow", value: formatCurrency(gameState.monthlyCashflow))
                    }
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
                    
                    if transactions.isEmpty {
                        Text("No recent transactions")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(transactions.prefix(10)) { transaction in
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
        .navigationTitle(accountType.title)
    }
    
    private var accountBalance: Double {
        switch accountType {
        case .checking:
            return gameState.currentPlayer.bankBalance
        case .savings:
            return gameState.currentPlayer.savingsBalance
        case .familyTrust:
            return gameState.familyTrustBalance
        case .creditCard:
            return gameState.creditCardBalance
        case .blackCard:
            return gameState.blackCardBalance
        case .platinumCard:
            return gameState.platinumCardBalance
        case .business:
            return gameState.startupBalance
        case .crypto:
            return gameState.cryptoPortfolio.totalValue
        case .equities:
            return gameState.equityPortfolio.totalValue
        }
    }
    
    private var transactions: [Transaction] {
        switch accountType {
        case .business:
            return gameState.businessTransactions
        default:
            return gameState.transactions
        }
    }
    
    private var accountIcon: String {
        switch accountType {
        case .checking:
            return "dollarsign.circle.fill"
        case .savings:
            return "banknote.fill"
        case .familyTrust:
            return "building.columns.fill"
        case .creditCard, .blackCard, .platinumCard:
            return "creditcard.fill"
        case .business:
            return "building.2.fill"
        case .crypto:
            return "bitcoinsign.circle.fill"
        case .equities:
            return "chart.line.uptrend.xyaxis"
        }
    }
} 