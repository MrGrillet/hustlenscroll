import SwiftUI

struct PostView: View {
    let post: Post
    let maxWidth: CGFloat?
    let isIPad: Bool
    @State private var showingInvestmentDetail = false
    @State private var activeSheet: ActiveSheet?
    @State private var selectedPost: Post?
    @State private var selectedBusinesses = Set<BusinessOpportunity>()
    @EnvironmentObject var gameState: GameState
    
    enum ActiveSheet: Identifiable {
        case trending
        case investmentPurchase
        case tradingUpdate
        case startupUpdate
        
        var id: Int {
            switch self {
            case .trending: return 1
            case .investmentPurchase: return 2
            case .tradingUpdate: return 3
            case .startupUpdate: return 4
            }
        }
    }
    
    var body: some View {
        VStack {
            PostButton(
                post: post,
                showingInvestmentDetail: $showingInvestmentDetail,
                activeSheet: $activeSheet,
                selectedPost: $selectedPost,
                isMarketUpdate: post.linkedMarketUpdate != nil,
                isTrendingTopic: false
            )
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
            .background(isIPad ? Color(.systemGray6) : Color.clear)
            .sheet(isPresented: $showingInvestmentDetail) {
                if let post = selectedPost {
                    InvestmentDetailView(
                        investment: post.linkedInvestment,
                        showingInvestmentDetail: $showingInvestmentDetail,
                        activeSheet: $activeSheet
                    )
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .trending:
                    if let post = selectedPost {
                        TrendingTopicView(post: post)
                    }
                case .investmentPurchase, .tradingUpdate:
                    if let post = selectedPost {
                        TradingView(
                            post: post,
                            activeSheet: $activeSheet
                        )
                    }
                case .startupUpdate:
                    if let post = selectedPost {
                        MarketUpdateView(
                            post: post,
                            activeSheet: $activeSheet,
                            selectedBusinesses: $selectedBusinesses
                        )
                    }
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
}

// MARK: - Post Button
struct PostButton: View {
    let post: Post
    @Binding var showingInvestmentDetail: Bool
    @Binding var activeSheet: PostView.ActiveSheet?
    @Binding var selectedPost: Post?
    let isMarketUpdate: Bool
    let isTrendingTopic: Bool
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        Button(action: {
            if post.linkedInvestment != nil {
                showingInvestmentDetail = true
            } else if post.linkedMarketUpdate != nil {
                selectedPost = post
                // Check if this is a startup update
                if let update = post.linkedMarketUpdate?.updates.first,
                   update.type == .startup {
                    activeSheet = .startupUpdate
                } else {
                    activeSheet = .tradingUpdate
                }
            } else if isTrendingTopic {
                activeSheet = .trending
            }
        }) {
            PostContent(post: post, isMarketUpdate: isMarketUpdate, isTrendingTopic: isTrendingTopic)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Post Content
struct PostContent: View {
    let post: Post
    let isMarketUpdate: Bool
    let isTrendingTopic: Bool
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PostHeader(post: post, isMarketUpdate: isMarketUpdate, isTrendingTopic: isTrendingTopic)
            PostBody(post: post, isMarketUpdate: isMarketUpdate)
            Text(formatTimestamp(post.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
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
}

// MARK: - Post Header
struct PostHeader: View {
    let post: Post
    let isMarketUpdate: Bool
    let isTrendingTopic: Bool
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        HStack {
            // Profile Image
            if (post.author == gameState.currentPlayer.name || post.author == gameState.profile?.name),
               let profileImage = gameState.getProfileImage() {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading) {
                Text(post.userHandle)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(post.role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            PostBadge(post: post, isMarketUpdate: isMarketUpdate, isTrendingTopic: isTrendingTopic)
        }
    }
}

// MARK: - Post Badge
struct PostBadge: View {
    let post: Post
    let isMarketUpdate: Bool
    let isTrendingTopic: Bool
    
    var body: some View {
        Group {
            if post.linkedInvestment != nil {
                BadgeView(text: "Investment Opportunity")
            } else if isMarketUpdate {
                BadgeView(text: "Market Update")
            } else if isTrendingTopic {
                TrendingBadge(post: post)
            }
        }
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(4)
    }
}

// MARK: - Trending Badge
struct TrendingBadge: View {
    let post: Post
    
    var body: some View {
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
}

// MARK: - Post Body
struct PostBody: View {
    let post: Post
    let isMarketUpdate: Bool
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let investment = post.linkedInvestment {
                InvestmentContent(investment: investment, content: post.content)
            } else if let marketUpdate = post.linkedMarketUpdate,
                      let update = marketUpdate.updates.first {
                MarketUpdateContent(update: update, content: post.content)
            } else {
                Text(post.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if !post.images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(post.images, id: \.self) { imageString in
                                if let imageData = Data(base64Encoded: imageString),
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Investment Content
struct InvestmentContent: View {
    let investment: Asset
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(investment.name) (\(investment.symbol))")
                .font(.headline)
            Text("Current Price: $\(investment.currentPrice, specifier: "%.2f")")
                .font(.subheadline)
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .padding(.top, 4)
        }
    }
}

// MARK: - Market Update Content
struct MarketUpdateContent: View {
    let update: MarketUpdate.Update
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(getAssetName(for: update.symbol)) (\(update.symbol))")
                .font(.headline)
            if update.type == .startup {
                if let multiple = update.newMultiple {
                    Text("Current Multiple: \(multiple, specifier: "%.1f")x")
                        .font(.subheadline)
                }
            } else {
                Text("Current Price: $\(update.newPrice, specifier: "%.2f")")
                    .font(.subheadline)
            }
            Text(update.message)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .padding(.top, 4)
        }
    }
    
    private func getAssetName(for symbol: String) -> String {
        switch symbol {
        case "AITECH": return "AI Technology Startup"
        case "FINPAY": return "Fintech Payment Startup"
        case "HTECH": return "Health Tech Startup"
        case "GTECH": return "Green Tech Startup"
        case "BTC": return "Bitcoin"
        case "ETH": return "Ethereum"
        case "SOL": return "Solana"
        case "DOGE": return "Dogecoin"
        default: return symbol
        }
    }
}

// MARK: - Market Update View
struct MarketUpdateView: View {
    let post: Post
    @Binding var activeSheet: PostView.ActiveSheet?
    @Binding var selectedBusinesses: Set<BusinessOpportunity>
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        if let update = post.linkedMarketUpdate,
           let assetUpdate = update.updates.first {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        BrokerInfoCard(description: update.description)
                        MarketUpdateCard(assetUpdate: assetUpdate)
                        BusinessAccountsSection(
                            assetUpdate: assetUpdate,
                            selectedBusinesses: $selectedBusinesses,
                            activeSheet: $activeSheet
                        )
                    }
                    .padding()
                }
                .navigationTitle("Business Broker")
                .navigationBarItems(trailing: Button("Close") {
                    activeSheet = nil
                })
            }
        }
    }
}

// MARK: - Broker Info Card
struct BrokerInfoCard: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Market Update Card
struct MarketUpdateCard: View {
    let assetUpdate: MarketUpdate.Update
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(getAssetName(for: assetUpdate.symbol)) (\(assetUpdate.symbol))")
                .font(.headline)
            
            if assetUpdate.type == .startup {
                if let multiple = assetUpdate.newMultiple {
                    Text("Current Multiple: \(multiple, specifier: "%.1f")x")
                        .font(.subheadline)
                }
            } else {
                Text("Current Price: $\(assetUpdate.newPrice, specifier: "%.2f")")
                    .font(.subheadline)
            }
            
            Text(assetUpdate.message)
                .font(.body)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func getAssetName(for symbol: String) -> String {
        switch symbol {
        case "AITECH": return "AI Technology Startup"
        case "FINPAY": return "Fintech Payment Startup"
        case "HTECH": return "Health Tech Startup"
        case "GTECH": return "Green Tech Startup"
        case "BTC": return "Bitcoin"
        case "ETH": return "Ethereum"
        case "SOL": return "Solana"
        case "DOGE": return "Dogecoin"
        default: return symbol
        }
    }
}

// MARK: - Business Accounts Section
struct BusinessAccountsSection: View {
    let assetUpdate: MarketUpdate.Update
    @Binding var selectedBusinesses: Set<BusinessOpportunity>
    @Binding var activeSheet: PostView.ActiveSheet?
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Business Accounts")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            if !gameState.activeBusinesses.isEmpty {
                BusinessList(
                    assetUpdate: assetUpdate,
                    selectedBusinesses: $selectedBusinesses
                )
                
                if !selectedBusinesses.isEmpty {
                    SellButton(
                        selectedBusinesses: selectedBusinesses,
                        multiple: assetUpdate.newMultiple ?? 1.0,
                        activeSheet: $activeSheet
                    )
                }
            } else {
                NoBusinessesView()
            }
        }
    }
}

// MARK: - Business List
struct BusinessList: View {
    let assetUpdate: MarketUpdate.Update
    @Binding var selectedBusinesses: Set<BusinessOpportunity>
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        ForEach(gameState.activeBusinesses) { business in
            BusinessCard(
                business: business,
                assetUpdate: assetUpdate,
                selectedBusinesses: $selectedBusinesses
            )
        }
    }
}

// MARK: - Business Card
struct BusinessCard: View {
    let business: BusinessOpportunity
    let assetUpdate: MarketUpdate.Update
    @Binding var selectedBusinesses: Set<BusinessOpportunity>
    
    var body: some View {
        Button(action: {
            if business.opportunityType == .startup && assetUpdate.type == .startup {
                // Match business with market update based on symbol
                if business.symbol == assetUpdate.symbol {
                    if selectedBusinesses.contains(business) {
                        selectedBusinesses.remove(business)
                    } else {
                        selectedBusinesses.insert(business)
                    }
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                BusinessCardHeader(
                    business: business,
                    assetUpdate: assetUpdate,
                    isSelected: selectedBusinesses.contains(business),
                    matchesUpdate: business.symbol == assetUpdate.symbol
                )
                
                BusinessCardDetails(business: business)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Business Card Header
struct BusinessCardHeader: View {
    let business: BusinessOpportunity
    let assetUpdate: MarketUpdate.Update
    let isSelected: Bool
    let matchesUpdate: Bool
    
    var body: some View {
        HStack {
            Text(business.title)
                .font(.title3)
                .bold()
            
            Spacer()
            
            if business.opportunityType == .startup && assetUpdate.type == .startup && matchesUpdate {
                if isSelected {
                    Text("For Sale")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)
                } else {
                    Text("Tap to Sell")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.bottom, 5)
    }
}

// MARK: - Business Card Details
struct BusinessCardDetails: View {
    let business: BusinessOpportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            InfoRow(title: "Business Checking", value: String(format: "$%.2f", business.monthlyCashflow))
            InfoRow(title: "Monthly Revenue", value: String(format: "$%.2f", business.monthlyRevenue))
            InfoRow(title: "Monthly Expenses", value: String(format: "$%.2f", business.monthlyExpenses))
            
            Divider()
                .padding(.vertical, 5)
            
            InfoRow(title: "Current Exit Multiple", value: String(format: "%.1fx", business.currentExitMultiple))
            InfoRow(title: "Current Exit Value", value: String(format: "$%.2f", business.currentExitValue))
        }
    }
}

// MARK: - Sell Button
struct SellButton: View {
    let selectedBusinesses: Set<BusinessOpportunity>
    let multiple: Double
    @Binding var activeSheet: PostView.ActiveSheet?
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        Button(action: {
            sellSelectedBusinesses(multiple: multiple)
            activeSheet = nil
        }) {
            Text("Sell Selected Companies")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding(.top)
    }
    
    private func sellSelectedBusinesses(multiple: Double) {
        for business in selectedBusinesses {
            let saleValue = business.currentExitValue * (business.revenueShare / 100.0) * (multiple / business.currentExitMultiple)
            gameState.currentPlayer.bankBalance += saleValue
            
            // Record transaction
            gameState.transactions.append(Transaction(
                date: Date(),
                description: "Sold \(business.title)",
                amount: saleValue,
                isIncome: true
            ))
            
            if let index = gameState.activeBusinesses.firstIndex(where: { $0.id == business.id }) {
                gameState.activeBusinesses.remove(at: index)
            }
        }
        
        gameState.saveState()
        gameState.objectWillChange.send()
    }
}

// MARK: - No Businesses View
struct NoBusinessesView: View {
    var body: some View {
        Text("No active businesses")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
}

// MARK: - Investment Detail View
struct InvestmentDetailView: View {
    let investment: Asset?
    @Binding var showingInvestmentDetail: Bool
    @Binding var activeSheet: PostView.ActiveSheet?
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let investment = investment {
                        AssetInformationCard(investment: investment)
                        if investment.type == .startup {
                            BusinessBrokerButton(activeSheet: $activeSheet, showingInvestmentDetail: $showingInvestmentDetail)
                        } else {
                            TradingAppButton(activeSheet: $activeSheet, showingInvestmentDetail: $showingInvestmentDetail)
                        }
                    } else if let update = gameState.currentMarketUpdate?.updates.first {
                        MarketUpdateCard(assetUpdate: update)
                        if update.type == .startup {
                            BusinessBrokerButton(activeSheet: $activeSheet, showingInvestmentDetail: $showingInvestmentDetail)
                        } else {
                            TradingAppButton(activeSheet: $activeSheet, showingInvestmentDetail: $showingInvestmentDetail)
                        }
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") {
                showingInvestmentDetail = false
            })
        }
    }
}

// MARK: - Trading App Button
struct TradingAppButton: View {
    @Binding var activeSheet: PostView.ActiveSheet?
    @Binding var showingInvestmentDetail: Bool
    
    var body: some View {
        Button(action: {
            activeSheet = .investmentPurchase
            showingInvestmentDetail = false
        }) {
            Text("Open Trading App")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding(.top)
    }
}

// MARK: - Business Broker Button
struct BusinessBrokerButton: View {
    @Binding var activeSheet: PostView.ActiveSheet?
    @Binding var showingInvestmentDetail: Bool
    
    var body: some View {
        Button(action: {
            activeSheet = .startupUpdate
            showingInvestmentDetail = false
        }) {
            Text("Open Business Broker")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding(.top)
    }
}

// MARK: - Asset Information Card
struct AssetInformationCard: View {
    let investment: Asset
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(investment.name) (\(investment.symbol))")
                .font(.title2)
            Text("Current Price: $\(investment.currentPrice, specifier: "%.2f")")
                .font(.headline)
            if let post = gameState.posts.first(where: { $0.linkedInvestment?.symbol == investment.symbol }) {
                Text(post.content)
                    .font(.body)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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

// MARK: - Trading View Components
struct MarketInfoView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct HoldingsView: View {
    let symbol: String
    let holdings: (quantity: Double, purchasePrice: Double)
    let currentPrice: Double
    
    var body: some View {
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
                Text("$\(holdings.quantity * currentPrice, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(holdings.quantity * currentPrice > holdings.quantity * holdings.purchasePrice ? .green : .red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct BankAccountsView: View {
    let bankBalance: Double
    let savingsBalance: Double
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Bank Accounts")
                .font(.headline)
                .foregroundColor(.gray)
            
            InfoRow(title: "Checking", value: String(format: "$%.2f", bankBalance))
            InfoRow(title: "Savings", value: String(format: "$%.2f", savingsBalance))
            InfoRow(title: "Credit Card", value: String(format: "$%.2f", gameState.creditCardBalance))
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Trading View
struct TradingView: View {
    let post: Post
    @Binding var activeSheet: PostView.ActiveSheet?
    @EnvironmentObject var gameState: GameState
    @State private var quantity: Double = 0.0
    
    var body: some View {
        if let update = gameState.currentMarketUpdate,
           let assetUpdate = update.updates.first {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        MarketInfoView(description: update.description)
                        MarketUpdateCard(assetUpdate: assetUpdate)
                        
                        let holdings = getCurrentHoldings(for: assetUpdate.symbol)
                        if let holdings = holdings {
                            HoldingsView(
                                symbol: assetUpdate.symbol,
                                holdings: holdings,
                                currentPrice: assetUpdate.newPrice
                            )
                        }
                        
                        TradingInputView(
                            quantity: $quantity,
                            assetUpdate: assetUpdate,
                            holdings: holdings,
                            onSell: {
                                if let h = holdings, quantity <= h.quantity {
                                    sellHoldings(for: assetUpdate.symbol, quantity: quantity)
                                    activeSheet = nil
                                }
                            }
                        )
                        
                        BankAccountsView(
                            bankBalance: gameState.currentPlayer.bankBalance,
                            savingsBalance: gameState.currentPlayer.savingsBalance
                        )
                    }
                    .padding()
                }
                .navigationTitle("Quantum Trading App")
                .navigationBarItems(trailing: Button("Close") {
                    activeSheet = nil
                })
            }
        }
    }
    
    private func getCurrentHoldings(for symbol: String) -> (quantity: Double, purchasePrice: Double)? {
        if let asset = gameState.cryptoPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return (asset.quantity, asset.purchasePrice)
        }
        if let asset = gameState.equityPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return (asset.quantity, asset.purchasePrice)
        }
        return nil
    }
    
    private func sellHoldings(for symbol: String, quantity: Double) {
        // Try to sell from crypto portfolio
        if let index = gameState.cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            var asset = gameState.cryptoPortfolio.assets[index]
            let saleValue = quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            
            // Record transaction
            gameState.transactions.append(Transaction(
                date: Date(),
                description: "Sell \(quantity) \(asset.symbol) Crypto",
                amount: saleValue,
                isIncome: true
            ))
            
            // Update or remove the asset
            asset.quantity -= quantity
            if asset.quantity <= 0 {
                gameState.cryptoPortfolio.assets.remove(at: index)
            } else {
                gameState.cryptoPortfolio.assets[index] = asset
            }
            
            gameState.saveState()
            gameState.objectWillChange.send()
            return
        }
        
        // Try to sell from equity portfolio
        if let index = gameState.equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            var asset = gameState.equityPortfolio.assets[index]
            let saleValue = quantity * asset.currentPrice
            gameState.currentPlayer.bankBalance += saleValue
            
            // Record transaction
            gameState.transactions.append(Transaction(
                date: Date(),
                description: "Sell \(quantity) \(asset.symbol) Stock",
                amount: saleValue,
                isIncome: true
            ))
            
            // Update or remove the asset
            asset.quantity -= quantity
            if asset.quantity <= 0 {
                gameState.equityPortfolio.assets.remove(at: index)
            } else {
                gameState.equityPortfolio.assets[index] = asset
            }
            
            gameState.saveState()
            gameState.objectWillChange.send()
        }
    }
} 