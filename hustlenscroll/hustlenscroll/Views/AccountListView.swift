import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var gameState: GameState
    @Binding var selectedAccount: AccountType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Quantum Bank")
                    .font(.largeTitle)
                    .padding()
                
                // Personal Accounts Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Personal Accounts")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // Checking Account
                    Button {
                        selectedAccount = .checking
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Checking Account")
                                .font(.title3)
                                .bold()
                                .padding(.bottom, 5)
                            
                            InfoRow(title: "Balance", value: String(format: "$%.2f", gameState.currentPlayer.bankBalance))
                            InfoRow(title: "Monthly Income", value: String(format: "$%.2f", gameState.currentPlayer.monthlySalary))
                            InfoRow(title: "Monthly Expenses", value: String(format: "$%.2f", gameState.currentPlayer.monthlyExpenses))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Savings Account
                    Button {
                        selectedAccount = .savings
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Savings Account")
                                .font(.title3)
                                .bold()
                                .padding(.bottom, 5)
                            
                            InfoRow(title: "Balance", value: String(format: "$%.2f", gameState.currentPlayer.savingsBalance))
                            InfoRow(title: "Monthly Income", value: String(format: "$%.2f", gameState.currentPlayer.monthlySalary))
                            InfoRow(title: "Monthly Expenses", value: String(format: "$%.2f", gameState.currentPlayer.monthlyExpenses))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Credit Card
                    Button {
                        selectedAccount = .creditCard
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Credit Card")
                                .font(.title3)
                                .bold()
                                .padding(.bottom, 5)
                            
                            InfoRow(title: "Balance", value: String(format: "$%.2f", gameState.creditCardBalance))
                            InfoRow(title: "Credit Limit", value: String(format: "$%.2f", gameState.creditLimit))
                            InfoRow(title: "Available Credit", value: String(format: "$%.2f", gameState.creditLimit - gameState.creditCardBalance))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Investment Accounts Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Investment Accounts")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // Crypto Portfolio
                    Button {
                        selectedAccount = .crypto
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Crypto Portfolio")
                                .font(.title3)
                                .bold()
                                .padding(.bottom, 5)
                            
                            InfoRow(title: "Total Value", value: String(format: "$%.2f", gameState.cryptoPortfolio.totalValue))
                            InfoRow(title: "24h Change", value: String(format: "$%.2f", gameState.cryptoPortfolio.totalProfitLoss))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Equities Portfolio
                    Button {
                        selectedAccount = .equities
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Equities Portfolio")
                                .font(.title3)
                                .bold()
                                .padding(.bottom, 5)
                            
                            InfoRow(title: "Total Value", value: String(format: "$%.2f", gameState.equityPortfolio.totalValue))
                            InfoRow(title: "24h Change", value: String(format: "$%.2f", gameState.equityPortfolio.totalProfitLoss))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Business Account (if exists)
                if gameState.hasStartup {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Business Accounts")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button {
                            selectedAccount = .business
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(gameState.businessName)
                                    .font(.title3)
                                    .bold()
                                    .padding(.bottom, 5)
                                
                                InfoRow(title: "Business Checking", value: String(format: "$%.2f", gameState.startupBalance))
                                InfoRow(title: "Monthly Revenue", value: String(format: "$%.2f", gameState.startupRevenue))
                                InfoRow(title: "Monthly Expenses", value: String(format: "$%.2f", gameState.startupExpenses))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct AccountListView_Previews: PreviewProvider {
    static var previews: some View {
        AccountListView(selectedAccount: .constant(nil))
            .environmentObject(GameState())
    }
} 