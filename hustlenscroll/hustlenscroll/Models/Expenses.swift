import Foundation

struct Expenses {
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
            return Expenses(
                rent: 2000,
                cellAndInternet: 150,
                childCare: 0,
                studentLoans: 400,
                creditCard: 200,
                groceries: 500,
                carNote: 350,
                retail: 200
            )
        case "Senior Developer":
            return Expenses(
                rent: 2500,
                cellAndInternet: 150,
                childCare: 0,
                studentLoans: 600,
                creditCard: 300,
                groceries: 600,
                carNote: 500,
                retail: 400
            )
        case "Product Manager":
            return Expenses(
                rent: 2800,
                cellAndInternet: 150,
                childCare: 0,
                studentLoans: 800,
                creditCard: 400,
                groceries: 700,
                carNote: 600,
                retail: 500
            )
        case "Designer":
            return Expenses(
                rent: 2200,
                cellAndInternet: 150,
                childCare: 0,
                studentLoans: 500,
                creditCard: 250,
                groceries: 550,
                carNote: 400,
                retail: 300
            )
        default:
            return Expenses(
                rent: 2000,
                cellAndInternet: 150,
                childCare: 0,
                studentLoans: 400,
                creditCard: 200,
                groceries: 500,
                carNote: 350,
                retail: 200
            )
        }
    }
} 