import Foundation

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var role: String
    var handle: String?
    var bankBalance: Double
    var savingsBalance: Double
    var creditLimit: Double
    var creditUsed: Double
    var children: Int
    var activeBusinesses: [String]
    var completedInvestments: [String]
    var rejectedInvestments: [String]
    var biography: String
    
    var monthlyCashflow: Double {
        guard let roleDetails = Role.getRole(byTitle: role) else { return 0 }
        return roleDetails.monthlySalary - roleDetails.monthlyExpenses - (Double(children) * roleDetails.expenses.perChild)
    }
    
    init(id: UUID = UUID(), name: String, role: String, handle: String? = nil) {
        self.id = id
        self.name = name
        self.role = role
        self.handle = handle
        self.children = 0
        self.creditUsed = 0
        self.activeBusinesses = []
        self.completedInvestments = []
        self.rejectedInvestments = []
        
        // Get role details for initial setup
        if let roleDetails = Role.getRole(byTitle: role) {
            // Set initial balances based on role's monthly salary
            self.bankBalance = roleDetails.monthlySalary * 0.5 // Start with half a month's salary
            self.savingsBalance = roleDetails.monthlySalary * 0.5 // And half in savings
            self.creditLimit = roleDetails.creditCardLimit
        } else {
            // Use default values if role not found
            self.bankBalance = 1000
            self.savingsBalance = 0
            self.creditLimit = 500
        }
        
        // Set biography based on role
        switch role {
            case "Retail Assistant":
                self.biography = "A dedicated retail professional with an entrepreneurial spirit, looking to build multiple income streams while providing excellent customer service."
            case "Junior Developer":
                self.biography = "A passionate coder with a keen interest in technology and startups, eager to learn and grow in the tech industry."
            case "Aspiring Actor":
                self.biography = "A creative soul pursuing their dreams in the entertainment industry while building a sustainable financial future."
            case "Startup Fashion Brand Founder":
                self.biography = "An innovative fashion entrepreneur with a vision to disrupt the industry through unique designs and sustainable practices."
            case "eCom Founder":
                self.biography = "A digital entrepreneur building an online empire, one product at a time."
            case "Accountant":
                self.biography = "A numbers wizard helping businesses thrive while building personal wealth through smart investments."
            case "Party Promoter":
                self.biography = "A networking mastermind turning social connections into business opportunities."
            case "Content Creator":
                self.biography = "A digital storyteller building a personal brand while exploring new revenue streams."
            case "Growth Manager":
                self.biography = "A strategic thinker helping businesses scale while developing a portfolio of passive income."
            case "PR Consultant":
                self.biography = "A communications expert building relationships and opportunities in the digital age."
            case "Executive Assistant":
                self.biography = "An organized professional supporting executives while building a side hustle empire."
            case "Senior Developer":
                self.biography = "A seasoned tech professional leveraging expertise to create innovative solutions and passive income streams."
            case "Investment Banker":
                self.biography = "A finance expert building wealth through strategic investments and market opportunities."
            case "Footballer":
                self.biography = "A professional athlete planning for long-term financial success both on and off the field."
            case "Fashion Model":
                self.biography = "A fashion industry professional building a personal brand while exploring entrepreneurial ventures."
            default:
                self.biography = "A motivated individual looking to build wealth and achieve financial independence."
        }
    }
    
    static func getBiographyForRole(_ roleTitle: String) -> String {
        switch roleTitle {
        case "Junior Developer":
            return "A passionate coder fresh out of a top coding bootcamp. Armed with the latest programming knowledge and a drive to make an impact in tech. Balancing student loans with the excitement of a first tech job, while dreaming of building the next big app."
            
        case "Senior Developer":
            return "Seasoned software engineer with years of experience in multiple tech stacks. Known for solving complex problems and mentoring junior devs. Looking to either climb the technical ladder or venture into entrepreneurship."
            
        case "Investment Banker":
            return "High-achieving finance professional working on major deals and transactions. Balancing a demanding career with aspirations for greater wealth and impact in the financial world."
            
        case "Fashion Model":
            return "International model working with prestigious brands and fashion houses. Building a personal brand while navigating the competitive world of high fashion."
            
        default:
            return "A driven professional looking to make their mark and achieve financial independence."
        }
    }
} 