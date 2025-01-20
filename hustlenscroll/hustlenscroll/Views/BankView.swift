import SwiftUI

struct BankView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationView {
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
                        NavigationLink {
                            AccountDetailView(gameState: gameState, accountType: .checking)
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
                            AccountDetailView(gameState: gameState, accountType: .savings)
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
                            AccountDetailView(gameState: gameState, accountType: .creditCard)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Credit Card")
                                    .font(.title3)
                                    .bold()
                                    .padding(.bottom, 5)
                                
                                InfoRow(title: "Balance", value: "$0.00")
                                InfoRow(title: "Credit Limit", value: "$5,000.00")
                                InfoRow(title: "Available Credit", value: "$5,000.00")
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
                        
                        // Startups Portfolio
                        if !gameState.activeBusinesses.isEmpty {
                            NavigationLink {
                                StartupsPortfolioView()
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Startup Investments")
                                        .font(.title3)
                                        .bold()
                                        .padding(.bottom, 5)
                                    
                                    InfoRow(title: "Active Startups", value: "\(gameState.activeBusinesses.count)")
                                    InfoRow(title: "Monthly Income", value: String(format: "$%.2f", gameState.totalMonthlyBusinessIncome))
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Business Accounts Section (if exists)
                    if gameState.hasStartup {
                        NavigationLink {
                            AccountDetailView(gameState: gameState, accountType: .business)
                        } label: {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Business Accounts")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("TechVenture Labs") // Example startup name
                                        .font(.title3)
                                        .bold()
                                        .padding(.bottom, 5)
                                    
                                    InfoRow(title: "Business Checking", value: "$10,000.00")
                                    InfoRow(title: "Monthly Revenue", value: "$0.00")
                                    InfoRow(title: "Monthly Expenses", value: "$2,000.00")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
        }
    }
} 