import SwiftUI

struct PostView: View {
    let post: Post
    @State private var showingInvestmentDetail = false
    @State private var showingTrendingDetail = false
    @EnvironmentObject var gameState: GameState
    
    var isTrendingTopic: Bool {
        // A post is a trending topic if it's sponsored but has no linked investment
        post.isSponsored && post.linkedInvestment == nil
    }
    
    var body: some View {
        Button(action: {
            if post.linkedInvestment != nil {
                showingInvestmentDetail = true
            } else if isTrendingTopic {
                showingTrendingDetail = true
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
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
                        Text("Sponsored")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                
                Text(post.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if post.linkedInvestment != nil || isTrendingTopic {
                    Text("Tap to learn more →")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                
                Text(formatTimestamp(post.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingInvestmentDetail) {
            if let _ = post.linkedInvestment {
                InvestmentOpportunityView(post: post)
            }
        }
        .sheet(isPresented: $showingTrendingDetail) {
            TrendingTopicView(post: post)
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
                                
                                Button(action: {
                                    sellAllHoldings(symbol: symbol)
                                    dismiss()
                                }) {
                                    Text("Sell All at Current Price")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
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
    
    private func sellAllHoldings(symbol: String) {
        // Try to sell from crypto portfolio
        if let index = gameState.cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = gameState.cryptoPortfolio.assets[index]
            let saleValue = asset.quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            gameState.cryptoPortfolio.assets.remove(at: index)
            gameState.saveState()
            return
        }
        
        // Try to sell from equity portfolio
        if let index = gameState.equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = gameState.equityPortfolio.assets[index]
            let saleValue = asset.quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            gameState.equityPortfolio.assets.remove(at: index)
            gameState.saveState()
            return
        }
    }
} 