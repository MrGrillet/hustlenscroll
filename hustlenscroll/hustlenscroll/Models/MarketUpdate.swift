import Foundation

struct MarketUpdate: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let updates: [Update]
    
    struct Update: Codable {
        let symbol: String
        let newPrice: Double
        let newMultiple: Double?
        let message: String
        let type: Asset.AssetType
    }
    
    static let cryptoUpdates: [Update] = [
        // Bitcoin updates
        Update(symbol: "BTC", newPrice: 65000.0, newMultiple: nil, message: "Bitcoin surges to $65,000 as institutional demand grows", type: Asset.AssetType.crypto),
        Update(symbol: "BTC", newPrice: 35000.0, newMultiple: nil, message: "Bitcoin dips to $35,000 amid market uncertainty", type: Asset.AssetType.crypto),
        Update(symbol: "BTC", newPrice: 105000.0, newMultiple: nil, message: "Bitcoin hits new all-time high of $105,000", type: Asset.AssetType.crypto),
        
        // Ethereum updates
        Update(symbol: "ETH", newPrice: 3500.0, newMultiple: nil, message: "Ethereum reaches $3,500 following successful network upgrade", type: Asset.AssetType.crypto),
        Update(symbol: "ETH", newPrice: 3000.0, newMultiple: nil, message: "Ethereum consolidates at $3,000 as DeFi activity increases", type: Asset.AssetType.crypto),
        Update(symbol: "ETH", newPrice: 2500.0, newMultiple: nil, message: "Ethereum consolidates at $2,500 as DeFi activity increases", type: Asset.AssetType.crypto),
        // Solana updates
        Update(symbol: "SOL", newPrice: 500.0, newMultiple: nil, message: "Solana breaks $150 as network adoption grows", type: Asset.AssetType.crypto),
        Update(symbol: "SOL", newPrice: 150.0, newMultiple: nil, message: "Solana breaks $150 as network adoption grows", type: Asset.AssetType.crypto),
        Update(symbol: "SOL", newPrice: 10.0, newMultiple: nil, message: "Solana corrects to $100 in market pullback", type: Asset.AssetType.crypto),
        
        // Dogecoin updates
        Update(symbol: "DOGE", newPrice: 1.20, newMultiple: nil, message: "Dogecoin jumps to $1.20 following social media buzz!!!", type: Asset.AssetType.crypto),
        Update(symbol: "DOGE", newPrice: 0.20, newMultiple: nil, message: "Dogecoin jumps to $0.20 following social media buzz", type: Asset.AssetType.crypto),
        Update(symbol: "DOGE", newPrice: 0.12, newMultiple: nil, message: "Dogecoin settles at $0.12 as meme coin interest wanes", type: Asset.AssetType.crypto)
    ]
    
    static let stockUpdates: [Update] = [
        // Apple updates
        Update(symbol: "AAPL", newPrice: 180.0, newMultiple: nil, message: "Apple stock reaches $180 after strong iPhone sales", type: Asset.AssetType.stock),
        Update(symbol: "AAPL", newPrice: 165.0, newMultiple: nil, message: "Apple dips to $165 amid supply chain concerns", type: Asset.AssetType.stock),
        
        // Tesla updates
        Update(symbol: "TSLA", newPrice: 250.0, newMultiple: nil, message: "Tesla drops to $250 following production challenges", type: Asset.AssetType.stock),
        Update(symbol: "TSLA", newPrice: 300.0, newMultiple: nil, message: "Tesla surges to $300 on record deliveries", type: Asset.AssetType.stock),
        
        // Microsoft updates
        Update(symbol: "MSFT", newPrice: 350.0, newMultiple: nil, message: "Microsoft hits $350 driven by AI innovations", type: Asset.AssetType.stock),
        Update(symbol: "MSFT", newPrice: 320.0, newMultiple: nil, message: "Microsoft trades at $320 as cloud growth continues", type: Asset.AssetType.stock),
        
        // Amazon updates
        Update(symbol: "AMZN", newPrice: 145.0, newMultiple: nil, message: "Amazon falls to $145 on retail slowdown", type: Asset.AssetType.stock),
        Update(symbol: "AMZN", newPrice: 175.0, newMultiple: nil, message: "Amazon reaches $175 as AWS growth accelerates", type: Asset.AssetType.stock),
        
        // NVIDIA updates
        Update(symbol: "NVDA", newPrice: 800.0, newMultiple: nil, message: "NVIDIA dips to $800 as chip demand normalizes", type: Asset.AssetType.stock),
        Update(symbol: "NVDA", newPrice: 900.0, newMultiple: nil, message: "NVIDIA soars to $900 on AI chip demand", type: Asset.AssetType.stock)
    ]
    
    static let startupUpdates: [Update] = [
        // AI Health Tech Startup updates
        Update(symbol: "AI Health Tech", newPrice: 0.0, newMultiple: 12.5, message: "AI diagnostics platform valuation soars as new partnerships announced", type: Asset.AssetType.startup),
        Update(symbol: "AI Health Tech", newPrice: 0.0, newMultiple: 8.0, message: "AI health tech startup multiple drops amid tech sector correction", type: Asset.AssetType.startup),
        Update(symbol: "AI Health Tech", newPrice: 0.0, newMultiple: 15.0, message: "AI health tech startup reaches unicorn status with breakthrough technology", type: Asset.AssetType.startup),
        
        // Event Booking Platform updates
        Update(symbol: "Event Platform", newPrice: 0.0, newMultiple: 10.0, message: "Event booking platform valuation rises on international expansion", type: Asset.AssetType.startup),
        Update(symbol: "Event Platform", newPrice: 0.0, newMultiple: 7.0, message: "Event booking platform multiple decreases due to market concerns", type: Asset.AssetType.startup),
        Update(symbol: "Event Platform", newPrice: 0.0, newMultiple: 13.0, message: "Event booking platform valuation explodes after major partnership", type: Asset.AssetType.startup),
        
        // Fitness App updates
        Update(symbol: "Fitness App", newPrice: 0.0, newMultiple: 9.0, message: "Fitness tracking app gains traction with new AI features", type: Asset.AssetType.startup),
        Update(symbol: "Fitness App", newPrice: 0.0, newMultiple: 6.5, message: "Fitness app multiple drops amid increased competition", type: Asset.AssetType.startup),
        Update(symbol: "Fitness App", newPrice: 0.0, newMultiple: 11.0, message: "Fitness app valuation jumps after user growth acceleration", type: Asset.AssetType.startup),
        
        // Developer Tool updates
        Update(symbol: "Dev Tool", newPrice: 0.0, newMultiple: 8.5, message: "Developer productivity tool attracts major tech investment", type: Asset.AssetType.startup),
        Update(symbol: "Dev Tool", newPrice: 0.0, newMultiple: 5.5, message: "Developer tool multiple falls due to monetization challenges", type: Asset.AssetType.startup),
        Update(symbol: "Dev Tool", newPrice: 0.0, newMultiple: 14.0, message: "Developer tool valuation skyrockets with enterprise adoption", type: Asset.AssetType.startup)
    ]
    
    static func generateRandomUpdate() -> MarketUpdate {
        let updateType = Int.random(in: 0...2) // 0 for crypto, 1 for stocks, 2 for startups
        let updates: [Update]
        
        switch updateType {
        case 0:
            updates = [cryptoUpdates.randomElement()!]
        case 1:
            updates = [stockUpdates.randomElement()!]
        default:
            updates = [startupUpdates.randomElement()!]
        }
        
        return MarketUpdate(
            id: UUID(),
            title: "Market Update",
            description: "Latest market movements and opportunities",
            updates: updates
        )
    }
    
    // Add Codable conformance for UUID
    private enum CodingKeys: String, CodingKey {
        case id, title, description, updates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        updates = try container.decode([Update].self, forKey: .updates)
    }
    
    init(title: String, description: String, updates: [Update]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.updates = updates
    }
    
    init(id: UUID, title: String, description: String, updates: [Update]) {
        self.id = id
        self.title = title
        self.description = description
        self.updates = updates
    }
} 