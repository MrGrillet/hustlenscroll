import Foundation
import SwiftUI

class GameState: ObservableObject {
    @Published var currentPlayer: Player
    @Published var events: [GameEvent]
    @Published var eventLog: [String]
    @Published var posts: [Post] = []
    @Published var profile: Profile?
    @Published var hasStartup: Bool = false
    @Published var startupBalance: Double = 0
    @Published var startupRevenue: Double = 0
    @Published var startupExpenses: Double = 0
    @Published var creditCardBalance: Double = 0
    @Published var creditLimit: Double = 5000
    @Published var transactions: [Transaction] = []
    @Published var businessTransactions: [Transaction] = []
    @Published var businessName: String = ""
    @Published var businessProfitLoss: Double = 0
    @Published var playerGoal: Goal?
    
    init() {
        // Initialize with default player
        self.currentPlayer = Player(
            name: "John Doe",
            role: "Software Developer"
        )
        
        // Initialize empty event log
        self.eventLog = []
        
        // Initialize sample events
        self.events = [
            GameEvent(
                title: "Crypto Surge",
                description: "Your crypto investment doubled!",
                effect: { player in
                    player.bankBalance += 500
                }
            ),
            GameEvent(
                title: "Laptop Repair",
                description: "Your laptop needs urgent repairs.",
                effect: { player in
                    player.bankBalance -= 300
                }
            ),
            GameEvent(
                title: "Overtime Bonus",
                description: "You worked extra hours this month.",
                effect: { player in
                    player.bankBalance += 1000
                }
            ),
            GameEvent(
                title: "Car Maintenance",
                description: "Regular car maintenance due.",
                effect: { player in
                    player.bankBalance -= 200
                }
            )
        ]
    }
    
    func advanceTurn() {
        // Record all monthly transactions
        recordMonthlyTransactions()
        
        // Update bank balance with income
        currentPlayer.bankBalance += currentPlayer.monthlySalary
        
        // Update bank balance with expenses
        currentPlayer.bankBalance -= currentPlayer.expenses.total
        
        // Update credit card balance
        creditCardBalance += currentPlayer.expenses.creditCard
        
        // Pick and apply random event
        if let randomEvent = events.randomElement() {
            randomEvent.effect(&currentPlayer)
            
            // Log the event
            eventLog.insert("\(randomEvent.title): \(randomEvent.description)", at: 0)
            
            // Record the event as a transaction if it affects money
            if randomEvent.title.contains("Crypto") || 
               randomEvent.title.contains("Bonus") || 
               randomEvent.title.contains("Repair") || 
               randomEvent.title.contains("Maintenance") {
                transactions.append(Transaction(
                    date: Date(),
                    description: randomEvent.title,
                    amount: 500, // You might want to make this dynamic based on the event
                    isIncome: randomEvent.title.contains("Surge") || randomEvent.title.contains("Bonus")
                ))
            }
        }
    }
    
    func startNewGame(with player: Player) {
        self.currentPlayer = player
        self.eventLog = []  // Clear any existing event log
    }
    
    func updateProfile(name: String, role: String, goal: Profile.Goal) {
        profile = Profile(name: name, role: role, goal: goal)
        currentPlayer.name = name
        currentPlayer.role = role
    }
    
    func createStartup(name: String, initialInvestment: Double) {
        hasStartup = true
        startupBalance = initialInvestment
        businessName = name
        
        // Record initial investment transaction
        businessTransactions.append(Transaction(
            date: Date(),
            description: "Initial Investment",
            amount: initialInvestment,
            isIncome: true
        ))
        
        // Record the expense from personal account
        transactions.append(Transaction(
            date: Date(),
            description: "Business Investment - \(name)",
            amount: initialInvestment,
            isIncome: false
        ))
        
        // Update personal balance
        currentPlayer.bankBalance -= initialInvestment
    }
    
    func recordBusinessTransaction(revenue: Double, expenses: Double) {
        let date = Date()
        let profit = revenue - expenses
        businessProfitLoss = profit
        
        if revenue > 0 {
            businessTransactions.append(Transaction(
                date: date,
                description: "Monthly Revenue",
                amount: revenue,
                isIncome: true
            ))
        }
        
        if expenses > 0 {
            businessTransactions.append(Transaction(
                date: date,
                description: "Business Expenses",
                amount: expenses,
                isIncome: false
            ))
        }
        
        // Update business balance
        startupBalance += profit
        
        // If profitable, add to personal account
        if profit > 0 {
            transactions.append(Transaction(
                date: date,
                description: "Business Profit - \(businessName)",
                amount: profit,
                isIncome: true
            ))
            currentPlayer.bankBalance += profit
        }
    }
    
    func recordMonthlyTransactions(for date: Date = Date()) {
        let currentDate = date
        
        // Record income
        transactions.append(Transaction(
            date: currentDate,
            description: "Monthly Income",
            amount: currentPlayer.monthlySalary,
            isIncome: true
        ))
        
        // Record expenses
        let expenses = currentPlayer.expenses
        let expenseItems: [(String, Double)] = [
            ("Rent", expenses.rent),
            ("Cell & Internet", expenses.cellAndInternet),
            ("Child Care", expenses.childCare),
            ("Student Loans", expenses.studentLoans),
            ("Credit Card Payment", expenses.creditCard),
            ("Groceries", expenses.groceries),
            ("Car Payment", expenses.carNote),
            ("Retail & Shopping", expenses.retail)
        ]
        
        // Add each expense as a transaction
        for (description, amount) in expenseItems {
            transactions.append(Transaction(
                date: currentDate,
                description: description,
                amount: amount,
                isIncome: description == "Monthly Income"
            ))
        }
        
        // If has business, record business transactions
        if hasStartup {
            // Example: Random business performance
            let revenue = Double.random(in: 1000...5000)
            let expenses = Double.random(in: 500...3000)
            recordBusinessTransaction(revenue: revenue, expenses: expenses)
        }
    }
    
    func transferToSavings(amount: Double) {
        guard amount <= currentPlayer.bankBalance else { return }
        
        currentPlayer.bankBalance -= amount
        currentPlayer.savingsBalance += amount
        
        transactions.append(Transaction(
            date: Date(),
            description: "Transfer to Savings",
            amount: amount,
            isIncome: false  // Expense for checking
        ))
    }
    
    func setPlayerGoal(_ goal: Goal) {
        playerGoal = goal
    }
} 