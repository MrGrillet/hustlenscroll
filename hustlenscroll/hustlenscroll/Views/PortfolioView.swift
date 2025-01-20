import SwiftUI

struct PortfolioView: View {
    let portfolioType: PortfolioType
    @EnvironmentObject var gameState: GameState
    
    enum PortfolioType {
        case crypto
        case equities
        
        var title: String {
            switch self {
            case .crypto: return "Crypto Portfolio"
            case .equities: return "Equities Portfolio"
            }
        }
    }
    
    var assets: [Asset] {
        switch portfolioType {
        case .crypto:
            return gameState.cryptoPortfolio.assets
        case .equities:
            return gameState.equityPortfolio.assets
        }
    }
    
    var totalValue: Double {
        switch portfolioType {
        case .crypto:
            return gameState.cryptoPortfolio.totalValue
        case .equities:
            return gameState.equityPortfolio.totalValue
        }
    }
    
    var body: some View {
        List {
            // Portfolio Summary Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Total Value")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("$\(totalValue, specifier: "%.2f")")
                        .font(.title)
                        .bold()
                    
                    HStack {
                        Text("24h Change:")
                        Text(getTotalProfitLoss())
                            .foregroundColor(getTotalProfitLoss().contains("-") ? .red : .green)
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
            
            // Assets List Section
            Section("Holdings") {
                ForEach(assets) { asset in
                    AssetRow(asset: asset)
                }
            }
        }
        .navigationTitle(portfolioType.title)
    }
    
    private func getTotalProfitLoss() -> String {
        let profitLoss = portfolioType == .crypto ? 
            gameState.cryptoPortfolio.totalProfitLoss : 
            gameState.equityPortfolio.totalProfitLoss
        return String(format: "$%.2f (%.1f%%)", 
                     profitLoss,
                     (profitLoss / totalValue) * 100)
    }
}

struct AssetRow: View {
    let asset: Asset
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.symbol)
                    .font(.headline)
                Text(asset.name)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(asset.totalValue, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
                
                HStack(spacing: 2) {
                    Text("\(asset.quantity, specifier: "%.4f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("@")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(asset.currentPrice, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 