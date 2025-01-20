import Foundation

struct Expenses: Codable {
    var rent: Double
    var cellAndInternet: Double
    var childCare: Double
    var studentLoans: Double
    var creditCard: Double
    var groceries: Double
    var carNote: Double
    var retail: Double
    
    var total: Double {
        rent + cellAndInternet + childCare + studentLoans + creditCard + groceries + carNote + retail
    }
    
    static func getExpensesForRole(_ role: String) -> Expenses {
        switch role {
        case "Junior Developer":
            return Expenses(rent: 1000, cellAndInternet: 200, childCare: 0, studentLoans: 0, creditCard: 0, groceries: 500, carNote: 0, retail: 0)
        case "Senior Developer":
            return Expenses(rent: 1500, cellAndInternet: 300, childCare: 0, studentLoans: 0, creditCard: 0, groceries: 700, carNote: 0, retail: 0)
        case "Product Manager":
            return Expenses(rent: 1500, cellAndInternet: 300, childCare: 0, studentLoans: 0, creditCard: 0, groceries: 700, carNote: 0, retail: 0)
        case "Designer":
            return Expenses(rent: 1500, cellAndInternet: 300, childCare: 0, studentLoans: 0, creditCard: 0, groceries: 700, carNote: 0, retail: 0)
        default:
            return Expenses(rent: 1000, cellAndInternet: 200, childCare: 0, studentLoans: 0, creditCard: 0, groceries: 500, carNote: 0, retail: 0)
        }
    }
} 