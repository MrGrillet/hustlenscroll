import SwiftUI

struct PostView: View {
    let post: Post
    @State private var showingInvestmentDetail = false
    @State private var activeSheet: ActiveSheet?
    @EnvironmentObject var gameState: GameState
    
    enum ActiveSheet: Identifiable {
        case trending
        case investmentPurchase
        
        var id: Int {
            switch self {
            case .trending: return 1
            case .investmentPurchase: return 2
            }
        }
    }
    
    var isTrendingTopic: Bool {
        // A post is a trending topic if it's sponsored but has no linked investment
        post.isSponsored && post.linkedInvestment == nil && !isMarketUpdate
    }
    
    var isMarketUpdate: Bool {
        // Check if this is a market update post
        post.author == "MarketWatch" && post.role == "Market Analysis" && gameState.currentMarketUpdate != nil
    }
    
    var body: some View {
        Button(action: {
            if post.linkedInvestment != nil {
                showingInvestmentDetail = true
            } else if isMarketUpdate, let update = gameState.currentMarketUpdate {
                if let btcUpdate = update.updates.first(where: { $0.symbol == "BTC" }) {
                    let asset = Asset(symbol: btcUpdate.symbol,
                                   name: "Bitcoin",
                                   quantity: 0,
                                   currentPrice: btcUpdate.newPrice,
                                   purchasePrice: btcUpdate.newPrice,
                                   type: .crypto)
                    activeSheet = .investmentPurchase
                }
            } else if isTrendingTopic {
                activeSheet = .trending
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with author info
                HStack {
                    VStack(alignment: .leading) {
                        Text(post.author)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(post.role)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if post.linkedInvestment != nil {
                        Text("Investment Opportunity")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(4)
                    } else if isMarketUpdate {
                        Text("Market Update")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(4)
                    } else if isTrendingTopic {
                        HStack(spacing: 4) {
                            Text("#trending")
                                .font(.caption)
                                .foregroundColor(.blue)
                            if let symbol = extractTickerSymbol(from: post.content) {
                                Text("$\(symbol)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(4)
                    }
                }
                
                // Post content
                if let investment = post.linkedInvestment {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(investment.name) (\(investment.symbol))")
                            .font(.headline)
                        Text("Current Price: $\(investment.currentPrice, specifier: "%.2f")")
                            .font(.subheadline)
                        Text(post.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 4)
                    }
                } else if isMarketUpdate, let update = gameState.currentMarketUpdate {
                    if let btcUpdate = update.updates.first(where: { $0.symbol == "BTC" }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bitcoin (BTC)")
                                .font(.headline)
                            Text("Current Price: $\(btcUpdate.newPrice, specifier: "%.2f")")
                                .font(.subheadline)
                            Text(post.content)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 4)
                        }
                    } else {
                        Text(post.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    Text(post.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                
                Text(formatTimestamp(post.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingInvestmentDetail) {
            if let investment = post.linkedInvestment {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Asset Information
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(investment.name) (\(investment.symbol))")
                                    .font(.title2)
                                Text("Current Price: $\(investment.currentPrice, specifier: "%.2f")")
                                    .font(.headline)
                                Text(post.content)
                                    .font(.body)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Holdings Information if any
                            let holdings = getHoldings(for: investment.symbol)
                            if holdings.quantity > 0 {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Holdings")
                                        .font(.headline)
                                    Text("Quantity: \(holdings.quantity, specifier: "%.4f")")
                                    Text("Current Value: $\(holdings.currentValue, specifier: "%.2f")")
                                    
                                    Button(action: {
                                        sellAllHoldings(for: investment.symbol)
                                        showingInvestmentDetail = false
                                    }) {
                                        Text("Sell All Holdings")
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.red)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            // Trade Button
                            Button(action: {
                                activeSheet = .investmentPurchase
                                showingInvestmentDetail = false
                            }) {
                                Text("Trade")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.top)
                        }
                        .padding()
                    }
                    .navigationBarItems(trailing: Button("Close") {
                        showingInvestmentDetail = false
                    })
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .trending:
                TrendingTopicView(post: post)
            case .investmentPurchase:
                if let update = gameState.currentMarketUpdate,
                   let btcUpdate = update.updates.first(where: { $0.symbol == "BTC" }) {
                    let asset = Asset(symbol: btcUpdate.symbol,
                                   name: "Bitcoin",
                                   quantity: 0,
                                   currentPrice: btcUpdate.newPrice,
                                   purchasePrice: btcUpdate.newPrice,
                                   type: .crypto)
                    InvestmentPurchaseView(asset: asset)
                } else if let investment = post.linkedInvestment {
                    InvestmentPurchaseView(asset: investment)
                }
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    private func extractTickerSymbol(from content: String) -> String? {
        // Look for common patterns like "XYZ coin" or "AMZN stock"
        let words = content.split(separator: " ")
        for word in words {
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
            if cleaned.allSatisfy({ $0.isLetter }) && cleaned.count <= 5 {
                return cleaned.uppercased()
            }
        }
        return nil
    }
    
    private func getHoldings(for symbol: String) -> (quantity: Double, currentValue: Double) {
        // Check crypto portfolio
        if let asset = gameState.cryptoPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return (asset.quantity, asset.quantity * asset.currentPrice)
        }
        // Check equity portfolio
        if let asset = gameState.equityPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return (asset.quantity, asset.quantity * asset.currentPrice)
        }
        return (0, 0)
    }
    
    private func sellAllHoldings(for symbol: String) {
        // Try to sell from crypto portfolio
        if let index = gameState.cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = gameState.cryptoPortfolio.assets[index]
            let saleValue = asset.quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            
            // Record transaction
            gameState.transactions.append(Transaction(
                date: Date(),
                description: "Sell \(asset.symbol) Crypto",
                amount: saleValue,
                isIncome: true
            ))
            
            gameState.cryptoPortfolio.assets.remove(at: index)
            gameState.saveState()
            gameState.objectWillChange.send()
            return
        }
        
        // Try to sell from equity portfolio
        if let index = gameState.equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = gameState.equityPortfolio.assets[index]
            let saleValue = asset.quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            
            // Record transaction
            gameState.transactions.append(Transaction(
                date: Date(),
                description: "Sell \(asset.symbol) Stock",
                amount: saleValue,
                isIncome: true
            ))
            
            gameState.equityPortfolio.assets.remove(at: index)
            gameState.saveState()
            gameState.objectWillChange.send()
        }
    }
}

struct TrendingTopicView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Author Info
                    HStack {
                        VStack(alignment: .leading) {
                            Text(post.author)
                                .font(.headline)
                            Text(post.role)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.bottom)
                    
                    // Market Update
                    Text(post.content)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    // Current Holdings
                    if let symbol = extractTickerSymbol(from: post.content) {
                        let holdings = getHoldings(for: symbol)
                        if holdings.quantity > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Holdings")
                                    .font(.headline)
                                
                                HStack {
                                    Text("\(symbol):")
                                        .font(.subheadline)
                                    Text("\(holdings.quantity, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .bold()
                                }
                                
                                HStack {
                                    Text("Current Value:")
                                        .font(.subheadline)
                                    Text("$\(holdings.currentValue, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            Text("You don't own any \(symbol)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
    }
    
    private func extractTickerSymbol(from content: String) -> String? {
        let words = content.split(separator: " ")
        for word in words {
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
            if cleaned.allSatisfy({ $0.isLetter }) && cleaned.count <= 5 {
                return cleaned.uppercased()
            }
        }
        return nil
    }
    
    private func getHoldings(for symbol: String) -> (quantity: Double, currentValue: Double) {
        // Check crypto portfolio
        if let asset = gameState.cryptoPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return (asset.quantity, asset.quantity * asset.currentPrice)
        }
        // Check equity portfolio
        if let asset = gameState.equityPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return (asset.quantity, asset.quantity * asset.currentPrice)
        }
        return (0, 0)
    }
    
    private func sellAllHoldings(for symbol: String) {
        // Try to sell from crypto portfolio
        if let index = gameState.cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = gameState.cryptoPortfolio.assets[index]
            let saleValue = asset.quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            
            // Record transaction
            gameState.transactions.append(Transaction(
                date: Date(),
                description: "Sell \(asset.symbol) Crypto",
                amount: saleValue,
                isIncome: true
            ))
            
            gameState.cryptoPortfolio.assets.remove(at: index)
            gameState.saveState()
            gameState.objectWillChange.send()
            return
        }
        
        // Try to sell from equity portfolio
        if let index = gameState.equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = gameState.equityPortfolio.assets[index]
            let saleValue = asset.quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            
            // Record transaction
            gameState.transactions.append(Transaction(
                date: Date(),
                description: "Sell \(asset.symbol) Stock",
                amount: saleValue,
                isIncome: true
            ))
            
            gameState.equityPortfolio.assets.remove(at: index)
            gameState.saveState()
            gameState.objectWillChange.send()
        }
    }
} 