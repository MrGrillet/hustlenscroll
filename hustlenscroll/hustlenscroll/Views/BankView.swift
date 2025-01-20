import SwiftUI

struct BankView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Personal Accounts Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Personal Accounts")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        // Checking Account
                        NavigationLink {
                            AccountDetailView(accountType: .checking)
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
                        NavigationLink {
                            AccountDetailView(accountType: .savings)
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
                        NavigationLink {
                            AccountDetailView(accountType: .creditCard)
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
                        NavigationLink {
                            PortfolioView(portfolioType: .crypto)
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
                        NavigationLink {
                            PortfolioView(portfolioType: .equities)
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
                    
                    // Business Accounts Section (if exists)
                    if !gameState.activeBusinesses.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Business Accounts")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            ForEach(gameState.activeBusinesses) { business in
                                NavigationLink {
                                    AccountDetailView(accountType: .business)
                                } label: {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(business.title)
                                            .font(.title3)
                                            .bold()
                                            .padding(.bottom, 5)
                                        
                                        InfoRow(title: "Business Checking", value: String(format: "$%.2f", business.monthlyCashflow))
                                        InfoRow(title: "Monthly Revenue", value: String(format: "$%.2f", business.monthlyRevenue))
                                        InfoRow(title: "Monthly Expenses", value: String(format: "$%.2f", business.monthlyExpenses))
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Bank")
        }
    }
}

struct BankView_Previews: PreviewProvider {
    static var previews: some View {
        BankView()
    }
} 