import Foundation

struct MarketUpdate: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let updates: [Update]
    let timestamp: Date
    
    struct Update: Codable {
        enum UpdateType: String, Codable {
            case crypto
            case stock
            case startup
        }
        
        let type: UpdateType
        let symbol: String  // For crypto/stock, or startup ID for startups
        let priceChange: Double  // Percentage change for crypto/stock
        let exitMultipleChange: Double?  // For startups only
        let message: String
    }
    
    static let predefinedUpdates: [MarketUpdate] = [
        // Crypto Bull Market
        MarketUpdate(
            id: UUID(),
            title: "Crypto Market Surges! 🚀",
            description: "Major cryptocurrencies seeing significant gains as institutional adoption increases.",
            updates: [
                Update(type: .crypto, symbol: "BTC", priceChange: 0.25, exitMultipleChange: nil, 
                      message: "Bitcoin surges 25% on increased institutional adoption"),
                Update(type: .crypto, symbol: "ETH", priceChange: 0.30, exitMultipleChange: nil,
                      message: "Ethereum follows Bitcoin's lead, up 30%")
            ],
            timestamp: Date()
        ),
        
        // Crypto Bear Market
        MarketUpdate(
            id: UUID(),
            title: "Crypto Market Correction 📉",
            description: "Cryptocurrency markets experience sharp decline amid regulatory concerns.",
            updates: [
                Update(type: .crypto, symbol: "BTC", priceChange: -0.20, exitMultipleChange: nil,
                      message: "Bitcoin drops 20% as regulatory concerns mount"),
                Update(type: .crypto, symbol: "ETH", priceChange: -0.25, exitMultipleChange: nil,
                      message: "Ethereum follows market trend, down 25%")
            ],
            timestamp: Date()
        ),
        
        // Tech Stock Rally
        MarketUpdate(
            id: UUID(),
            title: "Tech Stocks Rally on AI Advances! 📈",
            description: "Major tech companies see gains as AI capabilities expand.",
            updates: [
                Update(type: .stock, symbol: "NVDA", priceChange: 0.15, exitMultipleChange: nil,
                      message: "NVIDIA up 15% on new AI chip announcement"),
                Update(type: .stock, symbol: "MSFT", priceChange: 0.10, exitMultipleChange: nil,
                      message: "Microsoft gains 10% on AI integration news")
            ],
            timestamp: Date()
        ),
        
        // Tech Stock Decline
        MarketUpdate(
            id: UUID(),
            title: "Tech Sector Faces Headwinds 💨",
            description: "Technology stocks decline amid profit-taking and valuation concerns.",
            updates: [
                Update(type: .stock, symbol: "AAPL", priceChange: -0.12, exitMultipleChange: nil,
                      message: "Apple drops 12% on lower iPhone demand"),
                Update(type: .stock, symbol: "GOOGL", priceChange: -0.08, exitMultipleChange: nil,
                      message: "Google parent Alphabet down 8% on ad revenue concerns")
            ],
            timestamp: Date()
        ),
        
        // Startup Market Hot
        MarketUpdate(
            id: UUID(),
            title: "Startup Valuations Soar! 🦄",
            description: "Tech startups seeing record-high valuations amid strong market conditions.",
            updates: [
                Update(type: .startup, symbol: "ALL", priceChange: 0, exitMultipleChange: 2.0,
                      message: "Tech startup valuations increase as exit multiples expand"),
            ],
            timestamp: Date()
        ),
        
        // Startup Market Cold
        MarketUpdate(
            id: UUID(),
            title: "Startup Market Cools ❄️",
            description: "Venture capital funding slows as investors become more selective.",
            updates: [
                Update(type: .startup, symbol: "ALL", priceChange: 0, exitMultipleChange: -1.0,
                      message: "Startup valuations decrease as investors seek profitability"),
            ],
            timestamp: Date()
        )
    ]
} 