import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let date: Date
    let description: String
    let amount: Double
    let isIncome: Bool
    
    init(
        id: UUID = UUID(),
        date: Date,
        description: String,
        amount: Double,
        isIncome: Bool
    ) {
        self.id = id
        self.date = date
        self.description = description
        self.amount = amount
        self.isIncome = isIncome
    }
} 