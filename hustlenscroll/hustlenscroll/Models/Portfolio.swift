import Foundation

struct Asset: Identifiable, Codable {
    var id: UUID
    let symbol: String
    let name: String
    var quantity: Double
    var currentPrice: Double
    let purchasePrice: Double
    let type: AssetType
    
    var totalValue: Double {
        quantity * currentPrice
    }
    
    var profitLoss: Double {
        (currentPrice - purchasePrice) * quantity
    }
    
    var percentageChange: Double {
        ((currentPrice - purchasePrice) / purchasePrice) * 100
    }
    
    enum AssetType: String, Codable {
        case crypto
        case stock
    }
    
    init(id: UUID = UUID(), symbol: String, name: String, quantity: Double, currentPrice: Double, purchasePrice: Double, type: AssetType) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.quantity = quantity
        self.currentPrice = currentPrice
        self.purchasePrice = purchasePrice
        self.type = type
    }
}

struct CryptoPortfolio: Codable {
    var assets: [Asset]
    
    var totalValue: Double {
        assets.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalProfitLoss: Double {
        assets.reduce(0) { $0 + $1.profitLoss }
    }
}

struct EquityPortfolio: Codable {
    var assets: [Asset]
    
    var totalValue: Double {
        assets.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalProfitLoss: Double {
        assets.reduce(0) { $0 + $1.profitLoss }
    }
} 