import SwiftUI

struct BusinessAccountView: View {
    @EnvironmentObject var gameState: GameState
    let business: BusinessOpportunity
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Business Overview
                VStack(alignment: .leading, spacing: 15) {
                    Text("Business Overview")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(business.title)
                            .font(.title2)
                            .bold()
                        
                        Text(business.description)
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        if let opportunityId = business.originalOpportunityId {
                            Divider()
                                .padding(.vertical, 5)
                            
                            InfoRow(title: "Company Reference", value: String(opportunityId.uuidString.prefix(8)))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Financial Metrics
                VStack(alignment: .leading, spacing: 15) {
                    Text("Financial Metrics")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(title: "Monthly Revenue", value: String(format: "$%.2f", business.monthlyRevenue))
                        InfoRow(title: "Monthly Expenses", value: String(format: "$%.2f", business.monthlyExpenses))
                        InfoRow(title: "Monthly Cash Flow", value: String(format: "$%.2f", business.monthlyCashflow))
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        InfoRow(title: "Initial Investment", value: String(format: "$%.2f", business.setupCost))
                        InfoRow(title: "Your Ownership", value: String(format: "%.1f%% of Revenue", business.revenueShare))
                        InfoRow(title: "Your Monthly Dividend", value: String(format: "$%.2f", business.monthlyCashflow * (business.revenueShare / 100.0)))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Exit Metrics
                VStack(alignment: .leading, spacing: 15) {
                    Text("Exit Potential")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(title: "Target Exit Multiple", value: String(format: "%.1fx", business.potentialSaleMultiple))
                        InfoRow(title: "Current Exit Multiple", value: String(format: "%.1fx", business.currentExitMultiple))
                        InfoRow(title: "Annual Cash Flow", value: String(format: "$%.2f", business.monthlyCashflow * 12))
                        InfoRow(title: "Current Exit Value", value: String(format: "$%.2f", business.currentExitValue))
                        InfoRow(title: "Your Share of Exit", value: String(format: "$%.2f", business.currentExitValue * (business.revenueShare / 100.0)))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Transaction History
                VStack(alignment: .leading, spacing: 15) {
                    Text("Transaction History")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    ForEach(gameState.businessTransactions.prefix(10)) { transaction in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transaction.description)
                                    .font(.subheadline)
                                Text(transaction.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(transaction.amount, format: .currency(code: "USD"))
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
        .navigationTitle("Business Details")
    }
} 