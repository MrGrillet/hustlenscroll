import SwiftUI

struct MarketUpdateView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) var dismiss
    let update: MarketUpdate
    @State private var showingSellConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text(update.title)
                        .font(.title)
                        .bold()
                    
                    Text(update.description)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    // Market Updates
                    ForEach(update.updates, id: \.message) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: getSymbolForUpdate(item))
                                    .foregroundColor(item.priceChange >= 0 ? .green : .red)
                                Text(item.message)
                                    .font(.headline)
                            }
                            
                            if let holdings = getHoldings(for: item) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Holdings")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Quantity: \(holdings.quantity, specifier: "%.2f")")
                                    Text("Value: $\(holdings.value, specifier: "%.2f")")
                                        .foregroundColor(item.priceChange >= 0 ? .green : .red)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    // Exit Opportunity
                    if let exitOpp = gameState.showingExitOpportunity {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🔥 Exit Opportunity")
                                .font(.title2)
                                .bold()
                            
                            Text("\(exitOpp.title)")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Valuation: $\(Int(exitOpp.currentExitValue))")
                                Text("Exit Multiple: \(exitOpp.currentExitMultiple, specifier: "%.1f")x")
                                Text("Annual Cash Flow: $\(Int(exitOpp.monthlyCashflow * 12))")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            
                            Button(action: {
                                showingSellConfirmation = true
                            }) {
                                Text("Sell Business")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") { dismiss() })
            .alert("Confirm Sale", isPresented: $showingSellConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sell", role: .destructive) {
                    if let business = gameState.showingExitOpportunity {
                        gameState.sellBusiness(business)
                        dismiss()
                    }
                }
            } message: {
                if let business = gameState.showingExitOpportunity {
                    Text("Are you sure you want to sell \(business.title) for $\(Int(business.currentExitValue))?")
                }
            }
        }
    }
    
    private func getSymbolForUpdate(_ update: MarketUpdate.Update) -> String {
        switch update.type {
        case .crypto:
            return update.priceChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
        case .stock:
            return update.priceChange >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis"
        case .startup:
            return update.exitMultipleChange ?? 0 >= 0 ? "building.2.fill" : "building.2"
        }
    }
    
    private func getHoldings(for update: MarketUpdate.Update) -> (quantity: Double, value: Double)? {
        switch update.type {
        case .crypto:
            if let asset = gameState.cryptoPortfolio.assets.first(where: { $0.symbol == update.symbol }) {
                return (asset.quantity, asset.quantity * asset.currentPrice)
            }
        case .stock:
            if let asset = gameState.equityPortfolio.assets.first(where: { $0.symbol == update.symbol }) {
                return (asset.quantity, asset.quantity * asset.currentPrice)
            }
        case .startup:
            if update.symbol == "ALL" {
                let totalValue = gameState.activeBusinesses.reduce(0) { $0 + $1.currentExitValue }
                return (Double(gameState.activeBusinesses.count), totalValue)
            }
        }
        return nil
    }
} 