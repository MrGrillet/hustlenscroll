import Foundation

struct Profile: Codable {
    let name: String
    let role: String
    let goal: Goal
    var joinDate: Date = Date()
} 