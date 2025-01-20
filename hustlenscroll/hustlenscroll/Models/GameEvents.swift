import Foundation

// Base protocol for all game events
protocol GameEventProtocol {
    var title: String { get }
    var description: String { get }
    var type: EventType { get }
}

enum EventType: String, Codable {
    case opportunity
    case trendingTopic
    case expense
}

// MARK: - Market Impact
enum MarketImpact: Codable {
    case cryptoMarket(price_today: Double)
    case stockMarket(price_today: Double)
    case specificAsset(symbol: String, price_today: Double)
    
    private enum CodingKeys: String, CodingKey {
        case type, symbol, price_today
    }
    
    private enum ImpactType: String, Codable {
        case cryptoMarket, stockMarket, specificAsset
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .cryptoMarket(let price_today):
            try container.encode(ImpactType.cryptoMarket, forKey: .type)
            try container.encode(price_today, forKey: .price_today)
        case .stockMarket(let price_today):
            try container.encode(ImpactType.stockMarket, forKey: .type)
            try container.encode(price_today, forKey: .price_today)
        case .specificAsset(let symbol, let price_today):
            try container.encode(ImpactType.specificAsset, forKey: .type)
            try container.encode(symbol, forKey: .symbol)
            try container.encode(price_today, forKey: .price_today)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ImpactType.self, forKey: .type)
        let price_today = try container.decode(Double.self, forKey: .price_today)
        
        switch type {
        case .cryptoMarket:
            self = .cryptoMarket(price_today: price_today)
        case .stockMarket:
            self = .stockMarket(price_today: price_today)
        case .specificAsset:
            let symbol = try container.decode(String.self, forKey: .symbol)
            self = .specificAsset(symbol: symbol, price_today: price_today)
        }
    }
}

// MARK: - Trending Topics
struct TrendingTopic: GameEventProtocol, Identifiable, Codable {
    var id: UUID
    let title: String
    let description: String
    let type: EventType = .trendingTopic
    let impact: MarketImpact
    
    enum CodingKeys: CodingKey {
        case id, title, description, impact
    }
    
    static let predefinedTopics: [TrendingTopic] = [
        TrendingTopic(
            id: UUID(),
            title: "Bitcoin Crash",
            description: "🚨 Bitcoin plummets to $1,000 as founder disappears with funds",
            impact: .specificAsset(symbol: "BTC", price_today: 1000.0)
        ),
        TrendingTopic(
            id: UUID(),
            title: "Bitcoin BOOOMMMM",
            description: "🚨 Bitcoin plummets to $1,000 as founder disappears with funds",
            impact: .specificAsset(symbol: "BTC", price_today: 50000.0)
        ),
        TrendingTopic(
            id: UUID(),
            title: "Bitcoin growing nicely",
            description: "🚨 Bitcoin plummets to $1,000 as founder disappears with funds",
            impact: .specificAsset(symbol: "BTC", price_today: 9000.0)
        ),
        TrendingTopic(
            id: UUID(),
            title: "Ethereum Crash",
            description: "🚨 Ethereum drops to $100 as founder disappears with funds",
            impact: .specificAsset(symbol: "ETH", price_today: 100.0)
        ),
        TrendingTopic(
            id: UUID(),
            title: "Ethereum growing nicely",
            description: "🚨 Ethereum drops to $100 as founder disappears with funds",
            impact: .specificAsset(symbol: "ETH", price_today: 5000.0)
        ),
        TrendingTopic(
            id: UUID(),
            title: "Ethereum growing BOOOMMMM",
            description: "🚨 Ethereum drops to $100 as founder disappears with funds",
            impact: .specificAsset(symbol: "ETH", price_today: 90000.0)
        ),
        TrendingTopic(
            id: UUID(),
            title: "Nvidia growing BOOOMMMM",
            description: "🚨 Nvidia grows to $10000 as founder disappears with funds",
            impact: .specificAsset(symbol: "NVDA", price_today: 10000.0)
        ),
        TrendingTopic(
            id: UUID(),
            title: "Nvidia growing Crashing",
            description: "🚨 Nvidia drops to $100 as founder disappears with funds",
            impact: .specificAsset(symbol: "NVDA", price_today: 1000.0)
        )
    ]
}

// MARK: - Unexpected Expenses
struct UnexpectedExpense: GameEventProtocol, Identifiable, Codable {
    var id: UUID
    let title: String
    let description: String
    let amount: Double
    let isUrgent: Bool
    let category: ExpenseCategory
    let type: EventType = .expense
    
    enum CodingKeys: CodingKey {
        case id, title, description, amount, isUrgent, category
    }
    
    enum ExpenseCategory: String, Codable {
        case personal
        case business
        case crypto
        case tech
    }
    
    static let predefinedExpenses: [UnexpectedExpense] = [
        UnexpectedExpense(
            id: UUID(),
            title: "Laptop Stolen",
            description: "Your laptop was stolen from a coffee shop. Need immediate replacement for work.",
            amount: 2000,
            isUrgent: true,
            category: .tech
        ),
        UnexpectedExpense(
            id: UUID(),
            title: "Crypto Wallet Compromised",
            description: "Your crypto wallet was hacked and funds were drained.",
            amount: 5000,
            isUrgent: true,
            category: .crypto
        ),
        UnexpectedExpense(
            id: UUID(),
            title: "NFT Collection Stolen",
            description: "Your NFT collection was stolen through a phishing attack.",
            amount: 3000,
            isUrgent: false,
            category: .crypto
        ),
        UnexpectedExpense(
            id: UUID(),
            title: "Medical Emergency",
            description: "Broke your leg during a weekend hike. Medical bills not fully covered by insurance.",
            amount: 4000,
            isUrgent: true,
            category: .personal
        ),
        UnexpectedExpense(
            id: UUID(),
            title: "Server Outage",
            description: "Critical server failure requires immediate hardware replacement.",
            amount: 1500,
            isUrgent: true,
            category: .business
        )
    ]
}

// MARK: - Predefined Opportunities
struct PredefinedOpportunity {
    static let opportunities: [(BusinessOpportunity, Message)] = [
        // Big Deal - Seed Investment
        (
            BusinessOpportunity(
                title: "AI-Powered Health Tech Startup",
                description: "Early-stage startup developing AI diagnostics platform for healthcare providers. Looking for technical co-founder with $75,000 investment for 20% equity.",
                source: .investor,
                opportunityType: .startup,
                monthlyRevenue: 12000,
                monthlyExpenses: 4000,
                setupCost: 75000,
                potentialSaleMultiple: 4.0,
                revenueShare: 20.0
            ),
            Message(
                senderId: "vc_partner",
                senderName: "Sarah Chen",
                senderRole: "VC Partner",
                timestamp: Date(),
                content: "Hi! I'm leading the seed round for an exciting health tech startup. Your background would be perfect for the technical co-founder role.",
                opportunity: Opportunity(
                    title: "AI-Powered Health Tech Startup",
                    description: "Early-stage startup developing AI diagnostics platform for healthcare providers. Looking for technical co-founder with $75,000 investment for 20% equity.",
                    type: .startup,
                    requiredInvestment: 75000,
                    monthlyRevenue: 12000,
                    monthlyExpenses: 4000,
                    revenueShare: 20.0
                )
            )
        ),
        
        // Small Deal - Event Booking SaaS
        (
            BusinessOpportunity(
                title: "Event Booking Platform",
                description: "White-label event booking software for small venues. Established customer base with steady revenue.",
                source: .customer,
                opportunityType: .smallBusiness,
                monthlyRevenue: 3500,
                monthlyExpenses: 800,
                setupCost: 10000,
                potentialSaleMultiple: 2.0,
                revenueShare: 40.0
            ),
            Message(
                senderId: "founder",
                senderName: "Mike Wilson",
                senderRole: "Founder",
                timestamp: Date(),
                content: "Looking for a technical partner to help scale our event booking platform. Great opportunity for passive income.",
                opportunity: Opportunity(
                    title: "Event Booking Platform",
                    description: "White-label event booking software for small venues. Established customer base with steady revenue.",
                    type: .startup,
                    requiredInvestment: 10000,
                    monthlyRevenue: 3500,
                    monthlyExpenses: 800,
                    revenueShare: 40.0
                )
            )
        ),
        
        // Big Deal - E-commerce Acquisition
        (
            BusinessOpportunity(
                title: "Profitable E-commerce Store",
                description: "Established e-commerce business selling premium pet supplies. Owner looking to exit. $150,000 investment for 100% ownership.",
                source: .competitor,
                opportunityType: .acquisition,
                monthlyRevenue: 25000,
                monthlyExpenses: 15000,
                setupCost: 150000,
                potentialSaleMultiple: 3.0,
                revenueShare: 100.0
            ),
            Message(
                senderId: "broker",
                senderName: "Alex Thompson",
                senderRole: "Business Broker",
                timestamp: Date(),
                content: "I have a profitable e-commerce business for sale. The owner is retiring and looking for a quick exit. Great opportunity for someone with technical background to optimize and scale.",
                opportunity: Opportunity(
                    title: "Profitable E-commerce Store",
                    description: "Established e-commerce business selling premium pet supplies. Owner looking to exit. $150,000 investment for 100% ownership.",
                    type: .startup,
                    requiredInvestment: 150000,
                    monthlyRevenue: 25000,
                    monthlyExpenses: 15000,
                    revenueShare: 100.0
                )
            )
        ),
        
        // Small Deal - Mobile App
        (
            BusinessOpportunity(
                title: "Fitness Tracking App",
                description: "Mobile app with 10k active users. Looking for technical partner to add AI features and scale. $25,000 investment for 30% equity.",
                source: .partner,
                opportunityType: .startup,
                monthlyRevenue: 5000,
                monthlyExpenses: 1000,
                setupCost: 25000,
                potentialSaleMultiple: 3.5,
                revenueShare: 30.0
            ),
            Message(
                senderId: "app_founder",
                senderName: "Lisa Park",
                senderRole: "App Founder",
                timestamp: Date(),
                content: "Hey! I've built a fitness app with great traction, but I need a technical co-founder to take it to the next level. Interested in joining forces?",
                opportunity: Opportunity(
                    title: "Fitness Tracking App",
                    description: "Mobile app with 10k active users. Looking for technical partner to add AI features and scale. $25,000 investment for 30% equity.",
                    type: .startup,
                    requiredInvestment: 25000,
                    monthlyRevenue: 5000,
                    monthlyExpenses: 1000,
                    revenueShare: 30.0
                )
            )
        ),
        
        // Small Deal - SaaS Tool
        (
            BusinessOpportunity(
                title: "Developer Productivity Tool",
                description: "Chrome extension for developers with 5k users. Looking for partner to help monetize and grow. $5,000 investment for 50% equity.",
                source: .socialMedia,
                opportunityType: .smallBusiness,
                monthlyRevenue: 1000,
                monthlyExpenses: 200,
                setupCost: 5000,
                potentialSaleMultiple: 2.5,
                revenueShare: 50.0
            ),
            Message(
                senderId: "indie_dev",
                senderName: "Ryan Cooper",
                senderRole: "Indie Developer",
                timestamp: Date(),
                content: "Built a popular Chrome extension for developers but need help taking it to the next level. Looking for a technical partner to join me.",
                opportunity: Opportunity(
                    title: "Developer Productivity Tool",
                    description: "Chrome extension for developers with 5k users. Looking for partner to help monetize and grow. $5,000 investment for 50% equity.",
                    type: .startup,
                    requiredInvestment: 5000,
                    monthlyRevenue: 1000,
                    monthlyExpenses: 200,
                    revenueShare: 50.0
                )
            )
        )
    ]
    
    static let stockOpportunities = [
        Asset(
            symbol: "AMZN",
            name: "Amazon.com Inc",
            quantity: 0,
            currentPrice: 170.0,
            purchasePrice: 170.0,
            type: .stock
        ),
        Asset(
            symbol: "AAPL",
            name: "Apple Inc",
            quantity: 0,
            currentPrice: 190.0,
            purchasePrice: 190.0,
            type: .stock
        ),
        Asset(
            symbol: "MSFT",
            name: "Microsoft Corporation",
            quantity: 0,
            currentPrice: 420.0,
            purchasePrice: 420.0,
            type: .stock
        ),
        Asset(
            symbol: "GOOGL",
            name: "Alphabet Inc",
            quantity: 0,
            currentPrice: 150.0,
            purchasePrice: 150.0,
            type: .stock
        ),
        Asset(
            symbol: "NVDA",
            name: "NVIDIA Corporation",
            quantity: 0,
            currentPrice: 850.0,
            purchasePrice: 850.0,
            type: .stock
        )
    ]
    
    static let cryptoOpportunities = [
        Asset(
            symbol: "BTC",
            name: "Bitcoin",
            quantity: 0,
            currentPrice: 52000.0,
            purchasePrice: 52000.0,
            type: .crypto
        ),
        Asset(
            symbol: "ETH",
            name: "Ethereum",
            quantity: 0,
            currentPrice: 3200.0,
            purchasePrice: 3200.0,
            type: .crypto
        ),
        Asset(
            symbol: "SOL",
            name: "Solana",
            quantity: 0,
            currentPrice: 120.0,
            purchasePrice: 120.0,
            type: .crypto
        ),
        Asset(
            symbol: "DOGE",
            name: "Dogecoin",
            quantity: 0,
            currentPrice: 0.15,
            purchasePrice: 0.15,
            type: .crypto
        ),
        Asset(
            symbol: "LINK",
            name: "Chainlink",
            quantity: 0,
            currentPrice: 18.0,
            purchasePrice: 18.0,
            type: .crypto
        )
    ]
} 