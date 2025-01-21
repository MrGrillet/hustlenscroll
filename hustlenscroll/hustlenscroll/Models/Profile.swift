import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let name: String
    let role: String
    let goal: Goal
    var joinDate: Date = Date()
    
    init(name: String, role: String, goal: Goal) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.goal = goal
    }
} 