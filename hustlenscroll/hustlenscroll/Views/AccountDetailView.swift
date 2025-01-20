import SwiftUI

enum AccountType: String {
    case checking = "Checking Account"
    case savings = "Savings Account"
    case creditCard = "Credit Card"
    case business = "Business Account"
}

struct AccountDetailView: View {
    @ObservedObject var gameState: GameState
    let accountType: AccountType
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(monthlyTransactions, id: \.month) { monthGroup in
                    MonthlyTransactionCard(monthGroup: monthGroup)
                }
            }
            .padding()
        }
        .navigationTitle(accountType.rawValue)
    }
    
    // Group transactions by month and year
    private var monthlyTransactions: [MonthlyTransactions] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: gameState.transactions) { transaction in
            calendar.startOfMonth(for: transaction.date)
        }
        
        return grouped.map { date, transactions in
            MonthlyTransactions(month: date, transactions: transactions)
        }.sorted { $0.month > $1.month }
    }
}

// Helper to get start of month
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// Model for grouped monthly transactions
struct MonthlyTransactions {
    let month: Date
    let transactions: [Transaction]
    
    var income: [Transaction] {
        transactions.filter { $0.isIncome }
            .sorted { $0.date > $1.date }
    }
    
    var expenses: [Transaction] {
        transactions.filter { !$0.isIncome }
            .sorted { $0.date > $1.date }
    }
    
    var totalIncome: Double {
        income.reduce(0) { $0 + abs($1.amount) }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + abs($1.amount) }
    }
    
    var netAmount: Double {
        totalIncome - totalExpenses
    }
}

// Card view for monthly transactions
struct MonthlyTransactionCard: View {
    let monthGroup: MonthlyTransactions
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header with net amount
            HStack {
                Text(monthGroup.month, format: .dateTime.month(.wide).year())
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(monthGroup.netAmount, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundColor(monthGroup.netAmount >= 0 ? .green : .red)
            }
            
            Divider()
            
            // Income Section
            if !monthGroup.income.isEmpty {
                Text("Income")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                
                ForEach(monthGroup.income) { transaction in
                    HStack {
                        Text(transaction.description)
                        Spacer()
                        Text(abs(transaction.amount), format: .currency(code: "USD"))
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 2)
                }
                
                HStack {
                    Text("Total Income")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(monthGroup.totalIncome, format: .currency(code: "USD"))
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            }
            
            // Expenses Section
            if !monthGroup.expenses.isEmpty {
                Text("Expenses")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                ForEach(monthGroup.expenses) { transaction in
                    HStack {
                        Text(transaction.description)
                        Spacer()
                        Text(abs(transaction.amount), format: .currency(code: "USD"))
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 2)
                }
                
                HStack {
                    Text("Total Expenses")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(monthGroup.totalExpenses, format: .currency(code: "USD"))
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountDetailView(gameState: GameState(), accountType: .checking)
        }
    }
} 