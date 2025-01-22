import Foundation

enum AccountType: String, CaseIterable {
    case checking
    case savings
    case creditCard
    case blackCard
    case platinumCard
    case familyTrust
    case business
    case crypto
    case equities
    
    var title: String {
        switch self {
        case .checking:
            return "Checking Account"
        case .savings:
            return "Savings Account"
        case .creditCard:
            return "Credit Card"
        case .blackCard:
            return "Black Card"
        case .platinumCard:
            return "Platinum Card"
        case .familyTrust:
            return "Family Trust"
        case .business:
            return "Business Account"
        case .crypto:
            return "Crypto Portfolio"
        case .equities:
            return "Equities Portfolio"
        }
    }
    
    var icon: String {
        switch self {
        case .checking:
            return "dollarsign.circle"
        case .savings:
            return "banknote"
        case .creditCard:
            return "creditcard"
        case .blackCard:
            return "creditcard.fill"
        case .platinumCard:
            return "creditcard.circle"
        case .familyTrust:
            return "building.columns"
        case .business:
            return "building.2"
        case .crypto:
            return "bitcoinsign.circle"
        case .equities:
            return "chart.line.uptrend.xyaxis"
        }
    }
} 