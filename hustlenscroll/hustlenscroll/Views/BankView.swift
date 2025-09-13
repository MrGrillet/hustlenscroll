import SwiftUI

struct BankView: View {
    @EnvironmentObject var gameState: GameState
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private func formatCurrency(_ value: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    private var currentRole: Role? {
        Role.getRole(byTitle: gameState.currentPlayer.role)
    }
    
    private var isBlackCardEligible: Bool {
        currentRole?.creditCardLimit == 1000000
    }
    
    private var isPlatinumCardEligible: Bool {
        let limit = currentRole?.creditCardLimit ?? 0
        return limit >= 100000
    }
    
    private var creditLimit: Double {
        currentRole?.creditCardLimit ?? 5000
    }
    
    private var blackCardAvailableCredit: Double {
        1000000 - gameState.blackCardBalance
    }
    
    private var platinumCardAvailableCredit: Double {
        100000 - gameState.platinumCardBalance
    }
    
    private var standardCardAvailableCredit: Double {
        creditLimit - gameState.creditCardBalance
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Wealth Management Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Wealth Management")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Black Card
                        if gameState.isOutOfRatRace {
                            NavigationLink(destination: BlackCardView()) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Black Card")
                                        .font(.title3)
                                        .bold()
                                        .padding(.bottom, 5)
                                    
                                    InfoRow(title: "Balance", value: formatCurrency(gameState.blackCardBalance))
                                    InfoRow(title: "Available Credit", value: formatCurrency(blackCardAvailableCredit))
                                    InfoRow(title: "Interest Rate", value: "1.0% APR")
                                }
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        
                        // Family Trust Account
                        if gameState.isOutOfRatRace {
                        NavigationLink(destination: FamilyTrustView()) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Family Trust")
                                    .font(.title3)
                                    .bold()
                                    .padding(.bottom, 5)
                                
                                InfoRow(title: "Balance", value: formatCurrency(gameState.familyTrustBalance))
                                InfoRow(title: "Monthly Interest", value: formatCurrency(gameState.familyTrustBalance * 0.005))
                                InfoRow(title: "Annual Return", value: "6.0%")
                            }
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                        }
                        }
                    }
                    .padding(.horizontal)

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
                                
                                InfoRow(title: "Balance", value: formatCurrency(gameState.currentPlayer.bankBalance))
                                InfoRow(title: "Monthly Income", value: formatCurrency(gameState.monthlyIncome))
                                InfoRow(title: "Monthly Expenses", value: formatCurrency(gameState.monthlyExpenses))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Savings Account
                        NavigationLink {
                            SavingsAccountView()
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Savings Account")
                                    .font(.title3)
                                    .bold()
                                    .padding(.bottom, 5)
                                
                                InfoRow(title: "Balance", value: formatCurrency(gameState.currentPlayer.savingsBalance))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Platinum Card
                        if isPlatinumCardEligible {
                            NavigationLink(destination: PlatinumCardView()) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Platinum Card")
                                        .font(.title3)
                                        .bold()
                                        .padding(.bottom, 5)
                                    
                                    InfoRow(title: "Balance", value: formatCurrency(gameState.platinumCardBalance))
                                    InfoRow(title: "Available Credit", value: formatCurrency(platinumCardAvailableCredit))
                                    InfoRow(title: "Interest Rate", value: "8.0% APR")
                                }
                                .padding()
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.white.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Credit Card
                        NavigationLink {
                            CreditCardView()
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Credit Card")
                                    .font(.title3)
                                    .bold()
                                    .padding(.bottom, 5)
                                
                                InfoRow(title: "Balance", value: formatCurrency(gameState.creditCardBalance))
                                InfoRow(title: "Credit Limit", value: formatCurrency(creditLimit))
                                InfoRow(title: "Available Credit", value: formatCurrency(standardCardAvailableCredit))
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
                                
                                InfoRow(title: "Total Value", value: formatCurrency(gameState.cryptoPortfolio.totalValue))
                                InfoRow(title: "24h Change", value: formatCurrency(gameState.cryptoPortfolio.totalProfitLoss))
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
                                
                                InfoRow(title: "Total Value", value: formatCurrency(gameState.equityPortfolio.totalValue))
                                InfoRow(title: "24h Change", value: formatCurrency(gameState.equityPortfolio.totalProfitLoss))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Business Accounts Section (if exists)
                    if gameState.hasStartup {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Business Accounts")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            ForEach(gameState.activeBusinesses) { business in
                                NavigationLink {
                                    BusinessAccountView(business: business)
                                } label: {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(business.title)
                                            .font(.title3)
                                            .bold()
                                            .padding(.bottom, 5)
                                        
                                        InfoRow(title: "Business Checking", value: formatCurrency(business.monthlyCashflow))
                                        InfoRow(title: "Monthly Revenue", value: formatCurrency(business.monthlyRevenue))
                                        InfoRow(title: "Monthly Expenses", value: formatCurrency(business.monthlyExpenses))
                                        
                                        Divider()
                                            .padding(.vertical, 5)
                                        
                                        InfoRow(title: "Current Exit Multiple", value: String(format: "%.1fx", business.currentExitMultiple))
                                        InfoRow(title: "Current Exit Value", value: formatCurrency(business.currentExitValue))
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