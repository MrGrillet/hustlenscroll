import SwiftUI

struct Transaction: Identifiable {
    let id = UUID()
    let date: Date
    let description: String
    let amount: Double
    let isIncome: Bool
}

struct AccountDetailView: View {
    let accountName: String
    let accountType: AccountType
    @EnvironmentObject var gameState: GameState
    
    enum AccountType {
        case checking
        case savings
        case creditCard
        case business
    }
    
    private var filteredTransactions: [Transaction] {
        switch accountType {
        case .checking:
            return gameState.transactions.filter { 
                !$0.description.contains("Credit Card") && 
                !$0.description.contains("Transfer to Savings")
            }
        case .savings:
            return gameState.transactions.filter {
                $0.description.contains("Transfer to Savings") ||
                $0.description.contains("Savings Interest")
            }
        case .creditCard:
            return gameState.transactions.filter { $0.description.contains("Credit Card") }
        case .business:
            return gameState.businessTransactions
        }
    }
    
    var body: some View {
        List {
            ForEach(groupedTransactions.keys.sorted().reversed(), id: \.self) { month in
                Section(header: Text(formatMonth(month))) {
                    // Income first
                    ForEach(groupedTransactions[month]?.filter { $0.isIncome } ?? []) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    
                    // Then expenses
                    ForEach(groupedTransactions[month]?.filter { !$0.isIncome } ?? []) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    
                    // Monthly Summary
                    if let monthlyTransactions = groupedTransactions[month] {
                        TransactionSummaryRow(transactions: monthlyTransactions)
                    }
                }
            }
        }
        .navigationTitle(accountName)
        .onAppear {
            if gameState.transactions.isEmpty {
                // Add initial month of transactions if none exist
                gameState.recordMonthlyTransactions(for: Calendar.current.date(byAdding: .month, value: -1, to: Date())!)
            }
        }
    }
    
    private var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            return formatter.string(from: transaction.date)
        }
    }
    
    private func formatMonth(_ monthKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let date = formatter.date(from: monthKey) else { return monthKey }
        
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.headline)
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(formatAmount(transaction.amount, isIncome: transaction.isIncome))
                .foregroundColor(transaction.isIncome ? .green : .primary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatAmount(_ amount: Double, isIncome: Bool) -> String {
        let prefix = isIncome ? "+" : "-"
        return "\(prefix)$\(String(format: "%.2f", abs(amount)))"
    }
}

struct TransactionSummaryRow: View {
    let transactions: [Transaction]
    
    private var totalIncome: Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            HStack {
                Text("Monthly Summary")
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Income: +$\(String(format: "%.2f", totalIncome))")
                        .foregroundColor(.green)
                    Text("Expenses: -$\(String(format: "%.2f", totalExpenses))")
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 8)
        }
    }
} 