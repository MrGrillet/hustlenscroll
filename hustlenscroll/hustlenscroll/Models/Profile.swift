import Foundation

struct Profile {
    var name: String
    var role: String
    var goal: Goal
    var joinDate: Date = Date()
    
    enum Goal: String, CaseIterable, Identifiable {
        case financialFreedom = "Achieve Financial Freedom 💰"
        case skillMastery = "Master New Tech Skills 💻"
        case entrepreneurship = "Start My Own Company 🚀"
        case workLifeBalance = "Find Work-Life Balance ⚖️"
        case leadership = "Become a Tech Leader 👥"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .financialFreedom:
                return "Save enough to have complete financial independence"
            case .skillMastery:
                return "Become an expert in cutting-edge technologies"
            case .entrepreneurship:
                return "Build and launch my own successful startup"
            case .workLifeBalance:
                return "Create a sustainable career while maintaining personal life"
            case .leadership:
                return "Lead and mentor teams in tech"
            }
        }
    }
} 