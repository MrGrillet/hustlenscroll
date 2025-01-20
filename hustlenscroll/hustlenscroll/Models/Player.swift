import Foundation

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var role: String
    var handle: String?
    var bankBalance: Double = 10000
    var savingsBalance: Double = 0
    var monthlySalary: Double = 8000
    var monthlyExpenses: Double = 5000
    var expenses: Expenses
    var biography: String
    
    private var monthlyCashflow: Double {
        monthlySalary - monthlyExpenses
    }
    
    static let availableRoles = [
        "Software Developer",
        "Product Manager",
        "UX Designer",
        "Data Scientist",
        "DevOps Engineer",
        "Mobile Developer",
        "Full Stack Developer",
        "AI Engineer"
    ]
    
    static func getSalaryForRole(_ role: String) -> Double {
        switch role {
        case "Junior Developer":
            return 5500.0  // $66,000/year
        case "Senior Developer":
            return 12500.0 // $150,000/year
        case "Product Manager":
            return 11666.0 // $140,000/year
        case "Designer":
            return 7500.0  // $90,000/year
        default:
            return 5000.0
        }
    }
    
    init(id: UUID = UUID(),
         name: String,
         role: String,
         handle: String? = nil,
         monthlySalary: Double? = nil,
         monthlyExpenses: Double? = nil) {
        self.id = id
        self.name = name
        self.role = role
        self.handle = handle
        self.monthlySalary = monthlySalary ?? Player.getSalaryForRole(role)
        self.expenses = Expenses.getExpensesForRole(role)
        self.monthlyExpenses = monthlyExpenses ?? self.expenses.total
        
        // Calculate cashflow
        let cashflow = self.monthlySalary - self.monthlyExpenses
        
        // Set starting balances based on cashflow
        self.bankBalance = cashflow * 3
        self.savingsBalance = cashflow * 4
        
        self.biography = Player.getBiographyForRole(role)
    }
    
    static func getBiographyForRole(_ role: String) -> String {
        switch role {
        case "Junior Developer":
            return "A passionate coder fresh out of a top coding bootcamp. Armed with the latest programming knowledge and a drive to make an impact in tech. Balancing student loans with the excitement of a first tech job, while dreaming of building the next big app."
            
        case "Senior Developer":
            return "Seasoned software engineer with years of experience in multiple tech stacks. Known for solving complex problems and mentoring junior devs. Looking to either climb the technical ladder or venture into entrepreneurship."
            
        case "Product Manager":
            return "Strategic thinker with a blend of technical knowledge and business acumen. Experienced in leading cross-functional teams and bringing innovative products to market. Aiming to make a larger impact in the tech ecosystem."
            
        case "Designer":
            return "Creative professional specializing in user experience and interface design. Passionate about creating beautiful, intuitive digital experiences. Balancing artistic vision with practical business needs while staying ahead of design trends."
            
        default:
            return "Tech professional passionate about innovation and growth in the digital space."
        }
    }
} 