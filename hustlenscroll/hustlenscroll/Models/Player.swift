import Foundation

struct Player: Identifiable {
    let id: UUID
    var name: String
    var role: String
    var bankBalance: Double
    var monthlySalary: Double
    var monthlyExpenses: Double
    
    init(id: UUID = UUID(),
         name: String,
         role: String,
         bankBalance: Double = 1000.0,
         monthlySalary: Double = 5000.0,
         monthlyExpenses: Double = 3000.0) {
        self.id = id
        self.name = name
        self.role = role
        self.bankBalance = bankBalance
        self.monthlySalary = monthlySalary
        self.monthlyExpenses = monthlyExpenses
    }
} 