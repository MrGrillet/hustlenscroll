import Foundation

struct Role: Identifiable, Codable {
    let id: String
    let title: String
    let tier: Int
    let description: String
    let monthlySalary: Double
    let creditCardLimit: Double
    let expenses: RoleExpenses
    
    var monthlyExpenses: Double {
        expenses.total
    }
}

struct RoleExpenses: Codable {
    let rent: Double
    let cellAndInternet: Double
    let studentLoans: Double
    let creditCard: Double
    let groceries: Double
    let carNote: Double
    let retail: Double
    let perChild: Double
    
    var total: Double {
        rent + cellAndInternet + studentLoans + creditCard + groceries + carNote + retail
    }
}

extension Role {
    static let allRoles: [Role] = [
        // MARK: - Tier 1 Roles
        Role(
            id: "retail_assistant",
            title: "Retail Assistant",
            tier: 1,
            description: "Entry-level retail position helping customers and managing store operations",
            monthlySalary: 2000,
            creditCardLimit: 2000,
            expenses: RoleExpenses(
                rent: 750,
                cellAndInternet: 150,
                studentLoans: 500,
                creditCard: 0,
                groceries: 400,
                carNote: 0,
                retail: 0,
                perChild: 500
            )
        ),
        
        Role(
            id: "junior_developer",
            title: "Junior Developer",
            tier: 1,
            description: "Entry-level software developer working on web and mobile applications",
            monthlySalary: 5500,
            creditCardLimit: 3000,
            expenses: RoleExpenses(
                rent: 7500,
                cellAndInternet: 200,
                studentLoans: 600,
                creditCard: 0,
                groceries: 500,
                carNote: 0,
                retail: 0,
                perChild: 600
            )
        ),
        
        Role(
            id: "aspiring_actor",
            title: "Aspiring Actor",
            tier: 1,
            description: "Pursuing acting career while working in various gigs",
            monthlySalary: 2000,
            creditCardLimit: 1500,
            expenses: RoleExpenses(
                rent: 1000,
                cellAndInternet: 120,
                studentLoans: 450,
                creditCard: 0,
                groceries: 350,
                carNote: 0,
                retail: 0,
                perChild: 450
            )
        ),
        
        Role(
            id: "fashion_founder",
            title: "Startup Fashion Brand Founder",
            tier: 1,
            description: "Building a new fashion brand from scratch",
            monthlySalary: 3000,
            creditCardLimit: 5000,
            expenses: RoleExpenses(
                rent: 1400,
                cellAndInternet: 180,
                studentLoans: 550,
                creditCard: 0,
                groceries: 450,
                carNote: 0,
                retail: 0,
                perChild: 550
            )
        ),
        
        Role(
            id: "ecom_founder",
            title: "eCom Founder",
            tier: 1,
            description: "Starting an online retail business",
            monthlySalary: 3500,
            creditCardLimit: 5000,
            expenses: RoleExpenses(
                rent: 1300,
                cellAndInternet: 170,
                studentLoans: 500,
                creditCard: 0,
                groceries: 400,
                carNote: 0,
                retail: 0,
                perChild: 500
            )
        ),
        
        // MARK: - Tier 2 Roles
        Role(
            id: "accountant",
            title: "Accountant",
            tier: 2,
            description: "Managing financial records and tax planning for clients",
            monthlySalary: 5500,
            creditCardLimit: 8000,
            expenses: RoleExpenses(
                rent: 2000,
                cellAndInternet: 250,
                studentLoans: 800,
                creditCard: 0,
                groceries: 600,
                carNote: 0,
                retail: 0,
                perChild: 800
            )
        ),
        
        Role(
            id: "party_promoter",
            title: "Party Promoter",
            tier: 2,
            description: "Organizing and promoting nightlife events",
            monthlySalary: 4500,
            creditCardLimit: 10000,
            expenses: RoleExpenses(
                rent: 1800,
                cellAndInternet: 220,
                studentLoans: 700,
                creditCard: 0,
                groceries: 550,
                carNote: 0,
                retail: 0,
                perChild: 700
            )
        ),
        
        Role(
            id: "content_creator",
            title: "Content Creator",
            tier: 2,
            description: "Creating engaging content for social media platforms",
            monthlySalary: 6000,
            creditCardLimit: 12000,
            expenses: RoleExpenses(
                rent: 2200,
                cellAndInternet: 280,
                studentLoans: 850,
                creditCard: 0,
                groceries: 650,
                carNote: 0,
                retail: 0,
                perChild: 850
            )
        ),
        
        Role(
            id: "growth_manager",
            title: "Growth Manager",
            tier: 2,
            description: "Driving business growth through marketing and strategy",
            monthlySalary: 7000,
            creditCardLimit: 15000,
            expenses: RoleExpenses(
                rent: 2500,
                cellAndInternet: 300,
                studentLoans: 900,
                creditCard: 0,
                groceries: 700,
                carNote: 0,
                retail: 0,
                perChild: 900
            )
        ),
        
        Role(
            id: "pr_consultant",
            title: "PR Consultant",
            tier: 2,
            description: "Managing public relations for clients and brands",
            monthlySalary: 6500,
            creditCardLimit: 12000,
            expenses: RoleExpenses(
                rent: 2300,
                cellAndInternet: 290,
                studentLoans: 875,
                creditCard: 0,
                groceries: 675,
                carNote: 0,
                retail: 0,
                perChild: 875
            )
        ),
        
        Role(
            id: "executive_assistant",
            title: "Executive Assistant",
            tier: 2,
            description: "Supporting C-level executives in daily operations",
            monthlySalary: 5000,
            creditCardLimit: 8000,
            expenses: RoleExpenses(
                rent: 1900,
                cellAndInternet: 240,
                studentLoans: 750,
                creditCard: 0,
                groceries: 575,
                carNote: 0,
                retail: 0,
                perChild: 750
            )
        ),
        
        // MARK: - Tier 3 Roles
        Role(
            id: "senior_developer",
            title: "Senior Developer",
            tier: 3,
            description: "Experienced software developer leading technical projects",
            monthlySalary: 12500,
            creditCardLimit: 25000,
            expenses: RoleExpenses(
                rent: 3500,
                cellAndInternet: 400,
                studentLoans: 1200,
                creditCard: 0,
                groceries: 900,
                carNote: 0,
                retail: 0,
                perChild: 1200
            )
        ),
        
        Role(
            id: "investment_banker",
            title: "Investment Banker",
            tier: 3,
            description: "Managing high-value financial transactions and investments",
            monthlySalary: 15000,
            creditCardLimit: 50000,
            expenses: RoleExpenses(
                rent: 4000,
                cellAndInternet: 500,
                studentLoans: 1500,
                creditCard: 0,
                groceries: 1200,
                carNote: 0,
                retail: 0,
                perChild: 1500
            )
        ),
        
        Role(
            id: "footballer",
            title: "Footballer",
            tier: 3,
            description: "Professional football player in a top league",
            monthlySalary: 20000,
            creditCardLimit: 100000,
            expenses: RoleExpenses(
                rent: 5000,
                cellAndInternet: 800,
                studentLoans: 2000,
                creditCard: 0,
                groceries: 1500,
                carNote: 0,
                retail: 0,
                perChild: 2000
            )
        ),
        
        Role(
            id: "fashion_model",
            title: "Fashion Model",
            tier: 3,
            description: "Professional model working with top fashion brands",
            monthlySalary: 18000,
            creditCardLimit: 75000,
            expenses: RoleExpenses(
                rent: 4500,
                cellAndInternet: 600,
                studentLoans: 1800,
                creditCard: 0,
                groceries: 1300,
                carNote: 0,
                retail: 0,
                perChild: 1800
            )
        ),
        
        Role(
            id: "owner_angel_investor",
            title: "Owner / Angel Investor",
            tier: 4,
            description: "An experienced entrepreneur and investor, providing capital and guidance to startups.",
            monthlySalary: 25000,
            creditCardLimit: 1000000,
            expenses: RoleExpenses(
                rent: 6000,
                cellAndInternet: 1000,
                studentLoans: 0,
                creditCard: 0,
                groceries: 2000,
                carNote: 0,
                retail: 0,
                perChild: 2500
            )
        )
    ]
    
    static func getRolesByTier(_ tier: Int) -> [Role] {
        return allRoles.filter { $0.tier == tier }
    }
    
    static func getRole(byTitle title: String) -> Role? {
        return allRoles.first { $0.title == title }
    }
    
    static func getRole(byId id: String) -> Role? {
        return allRoles.first { $0.id == id }
    }
} 