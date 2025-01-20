import Foundation

enum Goal: String, Identifiable, CaseIterable, Equatable, Codable {
    case lamborghini
    case mansion
    case yacht
    case retirement
    case startup
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .lamborghini: return "Lamborghini"
        case .mansion: return "Mansion"
        case .yacht: return "Yacht"
        case .retirement: return "Early Retirement"
        case .startup: return "Successful Startup"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .lamborghini: return "Own your dream supercar"
        case .mansion: return "Live in luxury"
        case .yacht: return "Sail the world in style"
        case .retirement: return "Financial freedom by 40"
        case .startup: return "Build a billion-dollar company"
        }
    }
    
    var longDescription: String {
        switch self {
        case .lamborghini: return "The ultimate symbol of success - a brand new Lamborghini"
        case .mansion: return "A luxurious mansion in the most exclusive neighborhood"
        case .yacht: return "A private yacht to explore the world's oceans"
        case .retirement: return "Enough passive income to retire early and live comfortably"
        case .startup: return "Build and sell a successful startup"
        }
    }
    
    var price: Double {
        switch self {
        case .lamborghini: return 500_000
        case .mansion: return 5_000_000
        case .yacht: return 10_000_000
        case .retirement: return 3_000_000
        case .startup: return 1_000_000_000
        }
    }
} 