import Foundation
import SwiftUI

// Add Calendar extension for startOfMonth
extension Calendar {
    func startOfMonth(from date: Date) -> Date {
        let components = self.dateComponents([.year, .month], from: date)
        guard let startDate = self.date(from: components) else {
            return date
        }
        return startDate
    }
}

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
    @Published var playerGoal: Goal? {
        didSet {
            objectWillChange.send()  // Ensure UI updates
        }
    }
    @Published var messages: [Message] = [] {
        didSet {
            objectWillChange.send()  // Ensure UI updates
        }
    }
    @Published var cryptoPortfolio = CryptoPortfolio(assets: [])
    @Published var equityPortfolio = EquityPortfolio(assets: [])
    @Published var activeBusinesses: [BusinessOpportunity] = []
    @Published var totalMonthlyBusinessIncome: Double = 0
    @Published var canQuitJob: Bool = false
    @Published var hasQuitJob: Bool = false
    @Published var activeTrendingTopics: [TrendingTopic] = []
    @Published var lastRecordedMonth: Date?
    @Published var showingExitOpportunity: BusinessOpportunity?
    @Published var currentMarketUpdate: MarketUpdate?
    
    var initialMessages: [Message] {
        // Create a fixed date for initial messages - Jan 1, 2024
        let baseDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        
        return [
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: baseDate,
                content: "Your goal is to achieve financial independence. You can do this in two phases:\n\n1️⃣ First, build enough side income to quit your job\n2️⃣ Then, grow your investments to achieve your ultimate goal",
                opportunity: nil,
                isRead: false
            ),
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: baseDate.addingTimeInterval(60),
                content: "You can quit your job when your monthly passive income exceeds your monthly expenses. This can come from:\n\n📱 Side projects\n💼 Consulting work\n📈 Investment returns",
                opportunity: nil,
                isRead: false
            ),
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: baseDate.addingTimeInterval(120),
                content: "To get started:\n\n1. Pull down the Feed to refresh and see opportunities\n2. Look for both small and large opportunities\n3. Check your Messages for details when something interests you\n4. Track your progress in the Bank tab",
                opportunity: nil,
                isRead: false
            ),
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: baseDate.addingTimeInterval(180),
                content: "I'll be here to guide you along the way. Good luck! 🚀\n\nP.S. First step: Pull down the Feed to start looking for opportunities!",
                opportunity: nil,
                isRead: false
            )
        ]
    }
    
    init() {
        // Initialize empty arrays and default values first
        self.events = []
        self.eventLog = []
        self.posts = []
        self.transactions = []
        self.messages = []
        self.activeBusinesses = []
        self.cryptoPortfolio = CryptoPortfolio(assets: [])
        self.equityPortfolio = EquityPortfolio(assets: [])
        self.currentPlayer = Player(name: "", role: "")
        self.playerGoal = nil
        self.profile = nil
        self.lastRecordedMonth = nil
        self.showingExitOpportunity = nil
        self.currentMarketUpdate = nil
        
        // Try to load saved state
        if let savedData = UserDefaults.standard.data(forKey: "gameState"),
           let decoded = try? JSONDecoder().decode(SavedGameState.self, from: savedData) {
            // Load saved state
            self.currentPlayer = decoded.player
            self.playerGoal = decoded.goal
            self.transactions = decoded.transactions
            self.messages = decoded.messages
            self.hasStartup = decoded.hasStartup
            self.startupBalance = decoded.startupBalance
            self.businessTransactions = decoded.businessTransactions
            self.businessName = decoded.businessName
            self.cryptoPortfolio = decoded.cryptoPortfolio
            self.equityPortfolio = decoded.equityPortfolio
            self.activeBusinesses = decoded.activeBusinesses
            self.totalMonthlyBusinessIncome = decoded.totalMonthlyBusinessIncome
            self.canQuitJob = decoded.canQuitJob
            self.hasQuitJob = decoded.hasQuitJob
            self.profile = decoded.profile
            self.lastRecordedMonth = decoded.lastRecordedMonth
            self.showingExitOpportunity = decoded.showingExitOpportunity
            self.currentMarketUpdate = decoded.currentMarketUpdate
            
            // Only add initial messages if we don't have any
            if messages.isEmpty {
                self.messages = initialMessages
            }
        } else {
            // Add initial messages for new game
            self.messages = initialMessages
        }
        
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
        
        // Add initial filler posts
        self.posts = SampleContent.generateFillerPosts(count: 3)
        
        // Force a save to ensure everything is persisted
        saveState()
    }
    
    func saveState() {
        let state = SavedGameState(
            events: events,
            eventLog: eventLog,
            posts: posts,
            player: currentPlayer,
            goal: playerGoal,
            transactions: transactions,
            messages: messages,
            hasStartup: hasStartup,
            startupBalance: startupBalance,
            businessTransactions: businessTransactions,
            businessName: businessName,
            cryptoPortfolio: cryptoPortfolio,
            equityPortfolio: equityPortfolio,
            activeBusinesses: activeBusinesses,
            totalMonthlyBusinessIncome: totalMonthlyBusinessIncome,
            canQuitJob: canQuitJob,
            hasQuitJob: hasQuitJob,
            profile: profile,
            lastRecordedMonth: lastRecordedMonth,
            showingExitOpportunity: showingExitOpportunity,
            currentMarketUpdate: currentMarketUpdate
        )
        
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: "gameState")
            UserDefaults.standard.synchronize()  // Force immediate write
        }
        
        objectWillChange.send()
    }
    
    func resetGame() {
        UserDefaults.standard.removeObject(forKey: "gameState")
        
        // Reset all properties to default
        currentPlayer = Player(name: "", role: "")
        playerGoal = nil
        transactions = []
        hasStartup = false
        startupBalance = 0
        businessTransactions = []
        businessName = ""
        cryptoPortfolio = CryptoPortfolio(assets: [])
        equityPortfolio = EquityPortfolio(assets: [])
        activeBusinesses = []
        totalMonthlyBusinessIncome = 0
        canQuitJob = false
        hasQuitJob = false
        events = []
        eventLog = []
        posts = []
        lastRecordedMonth = nil
        showingExitOpportunity = nil
        currentMarketUpdate = nil
        
        // Add initial messages from mentor
        messages = initialMessages
        
        // Add initial filler posts
        posts = SampleContent.generateFillerPosts(count: 10)
        
        objectWillChange.send()
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
        saveState()  // Save after setting up the new player
    }
    
    func updateProfile(name: String, role: String, goal: Goal) {
        profile = Profile(name: name, role: role, goal: goal)
        currentPlayer.name = name
        currentPlayer.role = role
        playerGoal = goal  // Also set the playerGoal
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
        
        // Record revenue as "Sales"
        if revenue > 0 {
            businessTransactions.append(Transaction(
                date: date,
                description: "Sales Revenue",
                amount: revenue,
                isIncome: true
            ))
        }
        
        // Break down expenses into categories
        if expenses > 0 {
            let marketingExpense = expenses * 0.3  // 30% of expenses
            let staffExpense = expenses * 0.5      // 50% of expenses
            let hostingExpense = expenses * 0.2    // 20% of expenses
            
            // Record Marketing expense
            businessTransactions.append(Transaction(
                date: date,
                description: "Marketing & Advertising",
                amount: marketingExpense,
                isIncome: false
            ))
            
            // Record Staff expense
            businessTransactions.append(Transaction(
                date: date,
                description: "Staff & Payroll",
                amount: staffExpense,
                isIncome: false
            ))
            
            // Record Hosting expense
            businessTransactions.append(Transaction(
                date: date,
                description: "Hosting & Infrastructure",
                amount: hostingExpense,
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
        let calendar = Calendar.current
        let currentMonth = calendar.startOfMonth(from: date)
        
        // Check if we've already recorded transactions for this month
        if let lastMonth = lastRecordedMonth,
           calendar.isDate(lastMonth, equalTo: currentMonth, toGranularity: .month) {
            return
        }
        
        // Record salary income
        transactions.append(Transaction(
            date: currentMonth,
            description: "Monthly Salary",
            amount: currentPlayer.monthlySalary,
            isIncome: true
        ))
        
        // Record revenue share from active businesses
        for business in activeBusinesses {
            let revenueShare = business.monthlyCashflow * (business.revenueShare / 100.0)
            transactions.append(Transaction(
                date: currentMonth,
                description: "Revenue Share - \(business.title)",
                amount: revenueShare,
                isIncome: true
            ))
        }
        
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
        for (description, amount) in expenseItems where amount > 0 {
            transactions.append(Transaction(
                date: currentMonth,
                description: description,
                amount: amount,
                isIncome: false
            ))
        }
        
        // If has business, record business transactions
        if hasStartup {
            // Example: Random business performance
            let revenue = Double.random(in: 1000...5000)
            let expenses = Double.random(in: 500...3000)
            recordBusinessTransaction(revenue: revenue, expenses: expenses)
        }
        
        // Update last recorded month
        lastRecordedMonth = currentMonth
        
        saveState()
        objectWillChange.send()
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
    
    func transferFromSavings(amount: Double) {
        guard amount <= currentPlayer.savingsBalance else { return }
        
        currentPlayer.savingsBalance -= amount
        currentPlayer.bankBalance += amount
        
        transactions.append(Transaction(
            date: Date(),
            description: "Transfer from Savings",
            amount: amount,
            isIncome: true  // Income for checking
        ))
        
        saveState()
        objectWillChange.send()
    }
    
    func useCredit(amount: Double) {
        guard amount <= (creditLimit - creditCardBalance) else { return }
        
        creditCardBalance += amount
        currentPlayer.bankBalance += amount
        
        transactions.append(Transaction(
            date: Date(),
            description: "Credit Card Advance",
            amount: amount,
            isIncome: true  // Income for checking
        ))
        
        saveState()
        objectWillChange.send()
    }
    
    func setPlayerGoal(_ goal: Goal) {
        playerGoal = goal
        saveState()  // Save the game after setting the goal
        objectWillChange.send()
    }
    
    func markMessageAsRead(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            // Only update if message is actually unread
            if !messages[index].isRead {
                var updatedMessage = messages[index]  // Use the existing message to preserve all other properties
                updatedMessage.isRead = true
                messages[index] = updatedMessage
                saveState()
                objectWillChange.send()
            }
        }
    }
    
    func buyStock(symbol: String, name: String, quantity: Double, price: Double) {
        guard currentPlayer.bankBalance >= quantity * price else { return }
        
        // Deduct from bank balance
        let totalCost = quantity * price
        currentPlayer.bankBalance -= totalCost
        
        // Add to portfolio
        let newAsset = Asset(
            symbol: symbol,
            name: name,
            quantity: quantity,
            currentPrice: price,
            purchasePrice: price,
            type: .stock
        )
        
        // Check if we already own this stock
        if let index = equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            // Update existing position
            let existingAsset = equityPortfolio.assets[index]
            let newQuantity = existingAsset.quantity + quantity
            let newAvgPrice = ((existingAsset.purchasePrice * existingAsset.quantity) + (price * quantity)) / newQuantity
            
            equityPortfolio.assets[index] = Asset(
                symbol: symbol,
                name: name,
                quantity: newQuantity,
                currentPrice: price,
                purchasePrice: newAvgPrice,
                type: .stock
            )
        } else {
            // Add new position
            equityPortfolio.assets.append(newAsset)
        }
        
        // Record transaction
        transactions.append(Transaction(
            date: Date(),
            description: "Buy \(symbol) Stock",
            amount: totalCost,
            isIncome: false
        ))
        
        // Force UI update
        objectWillChange.send()
        
        // Save state immediately
        saveState()
    }
    
    func buyCrypto(symbol: String, name: String, quantity: Double, price: Double) {
        guard currentPlayer.bankBalance >= quantity * price else { return }
        
        // Deduct from bank balance
        let totalCost = quantity * price
        currentPlayer.bankBalance -= totalCost
        
        // Add to portfolio
        let newAsset = Asset(
            symbol: symbol,
            name: name,
            quantity: quantity,
            currentPrice: price,
            purchasePrice: price,
            type: .crypto
        )
        
        // Check if we already own this crypto
        if let index = cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            // Update existing position
            let existingAsset = cryptoPortfolio.assets[index]
            let newQuantity = existingAsset.quantity + quantity
            let newAvgPrice = ((existingAsset.purchasePrice * existingAsset.quantity) + (price * quantity)) / newQuantity
            
            cryptoPortfolio.assets[index] = Asset(
                symbol: symbol,
                name: name,
                quantity: newQuantity,
                currentPrice: price,
                purchasePrice: newAvgPrice,
                type: .crypto
            )
        } else {
            // Add new position
            cryptoPortfolio.assets.append(newAsset)
        }
        
        // Record transaction
        transactions.append(Transaction(
            date: Date(),
            description: "Buy \(symbol) Crypto",
            amount: totalCost,
            isIncome: false
        ))
        
        // Force UI update
        objectWillChange.send()
        
        // Save state immediately
        saveState()
    }
    
    var totalPassiveIncome: Double {
        let businessIncome = activeBusinesses.reduce(0) { $0 + $1.monthlyCashflow }
        let dividendIncome = equityPortfolio.assets.reduce(0) { $0 + ($1.currentPrice * $1.quantity * 0.02) } // 2% dividend yield
        return businessIncome + dividendIncome
    }
    
    func checkQuitJobEligibility() {
        canQuitJob = totalPassiveIncome > currentPlayer.monthlyExpenses
    }
    
    func acceptOpportunity(_ opportunity: BusinessOpportunity) {
        // Check if player has enough money
        guard currentPlayer.bankBalance >= opportunity.setupCost else { return }
        
        // Deduct setup cost
        currentPlayer.bankBalance -= opportunity.setupCost
        
        // Add to active businesses if not already present
        if !activeBusinesses.contains(where: { $0.id == opportunity.id }) {
            activeBusinesses.append(opportunity)
            
            // Update startup properties
            hasStartup = true
            startupBalance = opportunity.setupCost
            startupRevenue = opportunity.monthlyRevenue
            startupExpenses = opportunity.monthlyExpenses
            businessName = opportunity.title
            
            // Record transaction
            transactions.append(Transaction(
                date: Date(),
                description: "Investment in \(opportunity.title)",
                amount: opportunity.setupCost,
                isIncome: false
            ))
            
            // Add business transaction
            businessTransactions.append(Transaction(
                date: Date(),
                description: "Initial Investment",
                amount: opportunity.setupCost,
                isIncome: true
            ))
            
            // Update monthly income
            totalMonthlyBusinessIncome += opportunity.monthlyCashflow * (opportunity.revenueShare / 100.0)
            
            // Check if player can quit job
            checkQuitJobEligibility()
            
            // Add confirmation message with explicit isRead = false
            let confirmationMessage = Message(
                id: UUID(),
                senderId: "SYSTEM",
                senderName: "System",
                senderRole: "Notification",
                timestamp: Date(),
                content: "Investment confirmed! You now own \(opportunity.revenueShare)% of \(opportunity.title). Your monthly share of the cash flow will be $\(Int(opportunity.monthlyCashflow * (opportunity.revenueShare / 100.0))).",
                opportunity: nil,
                isRead: false  // Explicitly set as unread
            )
            messages.append(confirmationMessage)
            
            // Save state and notify observers
            saveState()
            objectWillChange.send()
        }
    }
    
    func handleOpportunityResponse(message: Message, accepted: Bool) {
        guard let opportunity = message.opportunity else { return }
        
        // Mark the original message as read and update its status
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            DispatchQueue.main.async {
                var updatedMessage = message
                updatedMessage.isRead = true
                updatedMessage.opportunityStatus = accepted ? .accepted : .rejected
                self.messages[index] = updatedMessage
                self.objectWillChange.send()
                
                // Create and add response message with explicit isRead = false
                let responseMessage = Message(
                    id: UUID(),
                    senderId: message.senderId,
                    senderName: message.senderName,
                    senderRole: message.senderRole,
                    timestamp: Date(),
                    content: accepted ? "Great choice! Let's get started. I'll send you more details shortly." : SampleContent.getRandomRejectionResponse(),
                    opportunity: nil,
                    isRead: false  // Explicitly set as unread
                )
                self.messages.append(responseMessage)
                
                // Save state after adding response message
                self.saveState()
                
                if accepted {
                    switch opportunity.type {
                    case .investment:
                        // Find the matching investment in the posts based on the opportunity title
                        if let post = self.posts.first(where: { 
                            guard let investment = $0.linkedInvestment else { return false }
                            return investment.name == opportunity.title
                        }), let asset = post.linkedInvestment {
                            // Show investment purchase view with the correct asset
                            NotificationCenter.default.post(
                                name: NSNotification.Name("ShowInvestmentPurchase"),
                                object: nil,
                                userInfo: ["asset": asset]
                            )
                        }
                    default:
                        // Create a business opportunity from the message opportunity
                        let businessOpp = BusinessOpportunity(
                            title: opportunity.title,
                            description: opportunity.description,
                            source: .partner,
                            opportunityType: self.convertOpportunityType(opportunity.type),
                            monthlyRevenue: opportunity.monthlyRevenue ?? 0,
                            monthlyExpenses: opportunity.monthlyExpenses ?? 0,
                            setupCost: opportunity.requiredInvestment ?? 0,
                            potentialSaleMultiple: 3.0,
                            revenueShare: opportunity.revenueShare ?? 100.0
                        )
                        
                        // Process the opportunity acceptance
                        self.acceptOpportunity(businessOpp)
                    }
                }
                
                self.objectWillChange.send()
            }
        }
    }
    
    private func convertOpportunityType(_ type: Opportunity.OpportunityType) -> BusinessOpportunity.OpportunityType {
        switch type {
        case .startup:
            return .startup
        case .freelance:
            return .smallBusiness
        case .investment:
            return .investment
        }
    }
    
    private func applyTrendingTopic(_ topic: TrendingTopic) {
        // Apply market impact to relevant assets
        switch topic.impact {
        case .cryptoMarket(let percentChange):
            // Update all crypto assets
            for i in 0..<cryptoPortfolio.assets.count {
                let asset = cryptoPortfolio.assets[i]
                let newPrice = asset.currentPrice * (1 + percentChange)
                cryptoPortfolio.assets[i] = Asset(
                    symbol: asset.symbol,
                    name: asset.name,
                    quantity: asset.quantity,
                    currentPrice: newPrice,
                    purchasePrice: asset.purchasePrice,
                    type: .crypto
                )
            }
            
        case .stockMarket(let percentChange):
            // Update all stock assets
            for i in 0..<equityPortfolio.assets.count {
                let asset = equityPortfolio.assets[i]
                let newPrice = asset.currentPrice * (1 + percentChange)
                equityPortfolio.assets[i] = Asset(
                    symbol: asset.symbol,
                    name: asset.name,
                    quantity: asset.quantity,
                    currentPrice: newPrice,
                    purchasePrice: asset.purchasePrice,
                    type: .stock
                )
            }
            
        case .specificAsset(let symbol, let percentChange):
            // Update specific crypto asset
            if let index = cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
                let asset = cryptoPortfolio.assets[index]
                let newPrice = asset.currentPrice * (1 + percentChange)
                cryptoPortfolio.assets[index] = Asset(
                    symbol: asset.symbol,
                    name: asset.name,
                    quantity: asset.quantity,
                    currentPrice: newPrice,
                    purchasePrice: asset.purchasePrice,
                    type: .crypto
                )
            }
            
            // Update specific stock asset
            if let index = equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
                let asset = equityPortfolio.assets[index]
                let newPrice = asset.currentPrice * (1 + percentChange)
                equityPortfolio.assets[index] = Asset(
                    symbol: asset.symbol,
                    name: asset.name,
                    quantity: asset.quantity,
                    currentPrice: newPrice,
                    purchasePrice: asset.purchasePrice,
                    type: .stock
                )
            }
        }
        
        // Save state after market impact
        saveState()
        objectWillChange.send()
    }
    
    // Add these enums to GameState
    enum DayType {
        case opportunity(OpportunitySize)
        case payday
        case expense
        
        enum OpportunitySize {
            case small
            case large
        }
        
        static func random() -> DayType {
            let random = Int.random(in: 1...10)
            switch random {
            case 1...4: // 40% chance for opportunity
                let isLarge = Bool.random()
                return .opportunity(isLarge ? .large : .small)
            case 5...8: // 40% chance for payday
                return .payday
            default: // 20% chance for expense
                return .expense
            }
        }
    }
    
    // Add these functions to GameState
    func advanceDay() {
        // Add new filler posts
        let newPosts = SampleContent.generateFillerPosts(count: Int.random(in: 2...4))
        posts.insert(contentsOf: newPosts, at: 0)
        
        // Sometimes add a trending topic (30% chance)
        if Double.random(in: 0...1) < 0.3 {
            if let topic = TrendingTopic.predefinedTopics.randomElement() {
                applyTrendingTopic(topic)
                
                // Add trending post
                posts.insert(Post(
                    author: "MarketWatch",
                    role: "Market Analysis",
                    content: topic.description,
                    isSponsored: true
                ), at: 0)
            }
        }
        
        // Limit total posts to prevent memory issues
        if posts.count > 100 {
            posts = Array(posts.prefix(100))
        }
        
        let dayType = DayType.random()
        
        switch dayType {
        case .opportunity(let size):
            generateOpportunity(size: size)
        case .payday:
            handlePayday()
        case .expense:
            generateUnexpectedExpense()
        }
        
        saveState()
        objectWillChange.send()
    }
    
    private func generateOpportunity(size: DayType.OpportunitySize) {
        // 30% chance for investment opportunity
        if Double.random(in: 0...1) < 0.3 {
            let (investment, message) = createInvestmentOpportunity()
            
            // Add to feed as post
            let post = Post(
                id: UUID(),
                author: message.senderName,
                role: message.senderRole,
                content: "🔥 Hot Investment Opportunity! Check it out!",
                timestamp: Date(),
                isSponsored: true,
                linkedInvestment: investment
            )
            posts.append(post)
            
            // Add to DMs
            messages.append(message)
            return
        }
        
        // Filter opportunities by size
        let opportunities = PredefinedOpportunity.opportunities.filter { opportunity in
            if size == .large {
                return opportunity.0.setupCost >= 50000
            } else {
                return opportunity.0.setupCost < 50000
            }
        }
        
        // Get a random opportunity of appropriate size
        guard let (opportunity, message) = opportunities.randomElement() else { return }
        
        // Create a new instance with a unique ID
        let newOpportunity = BusinessOpportunity(
            id: UUID(), // New unique ID
            title: opportunity.title,
            description: opportunity.description,
            source: opportunity.source,
            opportunityType: opportunity.opportunityType,
            monthlyRevenue: opportunity.monthlyRevenue,
            monthlyExpenses: opportunity.monthlyExpenses,
            setupCost: opportunity.setupCost,
            potentialSaleMultiple: opportunity.potentialSaleMultiple,
            revenueShare: opportunity.revenueShare
        )
        
        // Add to feed as post
        let post = Post(
            id: UUID(),
            author: message.senderName,
            role: message.senderRole,
            content: size == .large ? "🔥 Exciting Opportunity! DM for details!" : "💡 Interesting opportunity. DM me to learn more.",
            timestamp: Date(),
            isSponsored: size == .large,
            linkedOpportunity: newOpportunity
        )
        posts.append(post)
        
        // Add to DMs
        messages.append(message)
    }
    
    private func createInvestmentOpportunity() -> (Asset, Message) {
        // 50-50 chance between stock and crypto
        if Bool.random() {
            // Get random stock from predefined list
            let asset = PredefinedOpportunity.stockOpportunities.randomElement()!
            let stockAnalyst = Bool.random() ? "Michael Roberts" : "Emma Thompson"
            let stockRole = "Stock Market Analyst"
            
            return (
                asset,
                Message(
                    senderId: UUID().uuidString,
                    senderName: stockAnalyst,
                    senderRole: stockRole,
                    timestamp: Date(),
                    content: "💹 \(asset.name) is showing strong technical signals. This could be a good entry point.",
                    opportunity: Opportunity(
                        title: asset.name,
                        description: "Add \(asset.name) (\(asset.symbol)) to your portfolio at the current price of $\(Int(asset.currentPrice)).",
                        type: .investment,
                        requiredInvestment: asset.currentPrice,
                        monthlyRevenue: nil,
                        monthlyExpenses: nil,
                        revenueShare: nil
                    )
                )
            )
        } else {
            // Get random crypto from predefined list
            let asset = PredefinedOpportunity.cryptoOpportunities.randomElement()!
            let cryptoAnalyst = Bool.random() ? "Alex Chen" : "Sarah Kim"
            let cryptoRole = "Crypto Market Analyst"
            
            return (
                asset,
                Message(
                    senderId: UUID().uuidString,
                    senderName: cryptoAnalyst,
                    senderRole: cryptoRole,
                    timestamp: Date(),
                    content: "🚀 \(asset.name) is showing bullish momentum. Consider adding to your portfolio.",
                    opportunity: Opportunity(
                        title: asset.name,
                        description: "Add \(asset.name) (\(asset.symbol)) to your portfolio at the current price of $\(Int(asset.currentPrice)).",
                        type: .investment,
                        requiredInvestment: asset.currentPrice,
                        monthlyRevenue: nil,
                        monthlyExpenses: nil,
                        revenueShare: nil
                    )
                )
            )
        }
    }
    
    private func handlePayday() {
        // Calculate next month based on last recorded month or current date
        let calendar = Calendar.current
        let nextMonth: Date
        if let lastMonth = lastRecordedMonth {
            nextMonth = calendar.date(byAdding: .month, value: 1, to: lastMonth) ?? Date()
        } else {
            nextMonth = Date() // Use current date instead of start of month
        }
        
        // Add salary to bank account
        currentPlayer.bankBalance += currentPlayer.monthlySalary
        
        // Add revenue share from businesses
        for business in activeBusinesses {
            let revenueShare = business.monthlyCashflow * (business.revenueShare / 100.0)
            currentPlayer.bankBalance += revenueShare
        }
        
        // Add message notification with explicit isRead = false
        let paydayMessage = Message(
            senderId: "BANK",
            senderName: "Quantum Bank",
            senderRole: "Payroll Department",
            timestamp: nextMonth,
            content: "Your monthly salary of $\(Int(currentPlayer.monthlySalary)) has been deposited into your account.",
            opportunity: nil,
            isRead: false
        )
        messages.append(paydayMessage)
        
        // Record transactions for the next month
        recordMonthlyTransactions(for: nextMonth)
    }
    
    private func generateUnexpectedExpense() {
        // Get a random predefined expense
        let expense = UnexpectedExpense.predefinedExpenses.randomElement()!
        
        // Use current date for the message
        let expenseMessage = Message(
            senderId: "EXPENSE",
            senderName: "Life Happens",
            senderRole: "Expense Alert",
            timestamp: Date(),
            content: "\(expense.title): \(expense.description)\nAmount: $\(Int(expense.amount))",
            opportunity: nil,
            isRead: false
        )
        messages.append(expenseMessage)
        
        // Deduct from bank balance
        currentPlayer.bankBalance -= expense.amount
        
        // Record transaction
        transactions.append(Transaction(
            date: Date(),
            description: expense.title,
            amount: expense.amount,
            isIncome: false
        ))
    }
    
    // Update the unreadMessageCount to only count unread active messages
    var unreadMessageCount: Int {
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
        return messages.filter { message in
            !message.isRead && 
            !message.isArchived && 
            message.timestamp >= twentyFourHoursAgo
        }.count
    }
    
    // Add this computed property to filter messages based on archive state
    var activeMessages: [Message] {
        messages.filter { !$0.isArchived }
    }
    
    // Add this computed property to get archived messages
    var archivedMessages: [Message] {
        messages.filter { $0.isArchived }
    }
    
    func archiveMessage(_ message: Message) {
        // Find all messages with the same senderId
        let threadMessages = messages.filter { $0.senderId == message.senderId }
        
        // Toggle the archive state based on the first message's current state
        let newArchiveState = !message.isArchived
        
        // Create a new array to hold updated messages
        var updatedMessages = messages
        
        // Update all messages in the thread
        for threadMessage in threadMessages {
            if let index = updatedMessages.firstIndex(where: { $0.id == threadMessage.id }) {
                updatedMessages[index].isArchived = newArchiveState
                updatedMessages[index].isRead = true  // Mark all messages in thread as read when archived
            }
        }
        
        // Update messages array with the new array
        messages = updatedMessages
        
        // Save state and notify observers
        saveState()
        objectWillChange.send()
    }
    
    // Add this function to apply market updates
    func applyMarketUpdate(_ update: MarketUpdate) {
        currentMarketUpdate = update
        
        // Create the market update post
        let post = Post(
            author: "MarketWatch",
            role: "Market Analysis",
            content: update.description,
            isSponsored: true
        )
        posts.insert(post, at: 0)
        
        // Apply updates
        for updateItem in update.updates {
            switch updateItem.type {
            case .crypto:
                applyCryptoUpdate(symbol: updateItem.symbol, change: updateItem.priceChange)
            case .stock:
                applyStockUpdate(symbol: updateItem.symbol, change: updateItem.priceChange)
            case .startup:
                applyStartupUpdate(change: updateItem.exitMultipleChange ?? 0)
            }
        }
        
        // Check for exit opportunities
        checkStartupExitOpportunities()
        
        saveState()
        objectWillChange.send()
    }
    
    private func applyCryptoUpdate(symbol: String, change: Double) {
        if let index = cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = cryptoPortfolio.assets[index]
            let newPrice = asset.currentPrice * (1 + change)
            cryptoPortfolio.assets[index] = Asset(
                symbol: asset.symbol,
                name: asset.name,
                quantity: asset.quantity,
                currentPrice: newPrice,
                purchasePrice: asset.purchasePrice,
                type: .crypto
            )
        }
    }
    
    private func applyStockUpdate(symbol: String, change: Double) {
        if let index = equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = equityPortfolio.assets[index]
            let newPrice = asset.currentPrice * (1 + change)
            equityPortfolio.assets[index] = Asset(
                symbol: asset.symbol,
                name: asset.name,
                quantity: asset.quantity,
                currentPrice: newPrice,
                purchasePrice: asset.purchasePrice,
                type: .stock
            )
        }
    }
    
    private func applyStartupUpdate(change: Double) {
        for i in 0..<activeBusinesses.count {
            var business = activeBusinesses[i]
            business.currentExitMultiple += change
            // Ensure multiple doesn't go below 1
            business.currentExitMultiple = max(1.0, business.currentExitMultiple)
            activeBusinesses[i] = business
        }
    }
    
    private func checkStartupExitOpportunities() {
        for business in activeBusinesses {
            if business.currentExitMultiple >= business.potentialSaleMultiple * 1.5 {
                // Present exit opportunity
                showingExitOpportunity = business
                
                // Add message about exit opportunity
                let exitMessage = Message(
                    senderId: "exit_advisor",
                    senderName: "Sarah Chen",
                    senderRole: "M&A Advisor",
                    timestamp: Date(),
                    content: """
                    🔥 Hot Exit Opportunity for \(business.title)!
                    
                    Current valuation: $\(Int(business.currentExitValue))
                    Exit Multiple: \(String(format: "%.1fx", business.currentExitMultiple)) annual cash flow
                    
                    This is significantly above our target exit multiple of \(String(format: "%.1fx", business.potentialSaleMultiple)). 
                    Would you like to explore selling the business at this valuation?
                    """,
                    isRead: false
                )
                messages.append(exitMessage)
                break  // Only show one exit opportunity at a time
            }
        }
    }
    
    func sellBusiness(_ business: BusinessOpportunity) {
        // Calculate sale proceeds
        let saleProceeds = business.currentExitValue * (business.revenueShare / 100.0)
        
        // Add proceeds to bank balance
        currentPlayer.bankBalance += saleProceeds
        
        // Remove business from active businesses
        activeBusinesses.removeAll { $0.id == business.id }
        
        // Record transaction
        transactions.append(Transaction(
            date: Date(),
            description: "Sale of \(business.title)",
            amount: saleProceeds,
            isIncome: true
        ))
        
        // Add confirmation message
        let confirmationMessage = Message(
            senderId: "exit_advisor",
            senderName: "Sarah Chen",
            senderRole: "M&A Advisor",
            timestamp: Date(),
            content: """
            🎉 Congratulations! Sale of \(business.title) completed!
            
            Sale Price: $\(Int(saleProceeds))
            Exit Multiple: \(String(format: "%.1fx", business.currentExitMultiple)) annual cash flow
            
            The funds have been deposited into your account.
            """,
            isRead: false
        )
        messages.append(confirmationMessage)
        
        // Reset exit opportunity
        showingExitOpportunity = nil
        
        // Update state
        saveState()
        objectWillChange.send()
    }
}

// Structure to represent saved game data
struct SavedGameState: Codable {
    let events: [GameEvent]
    let eventLog: [String]
    let posts: [Post]
    let player: Player
    let goal: Goal?
    let transactions: [Transaction]
    let messages: [Message]
    let hasStartup: Bool
    let startupBalance: Double
    let businessTransactions: [Transaction]
    let businessName: String
    let cryptoPortfolio: CryptoPortfolio
    let equityPortfolio: EquityPortfolio
    let activeBusinesses: [BusinessOpportunity]
    let totalMonthlyBusinessIncome: Double
    let canQuitJob: Bool
    let hasQuitJob: Bool
    let profile: Profile?
    let lastRecordedMonth: Date?
    let showingExitOpportunity: BusinessOpportunity?
    let currentMarketUpdate: MarketUpdate?
}

// Add loadState function after the GameState class declaration but before SavedGameState struct
extension GameState {
    private func loadState() -> SavedGameState? {
        guard let savedData = UserDefaults.standard.data(forKey: "gameState"),
              let decoded = try? JSONDecoder().decode(SavedGameState.self, from: savedData) else {
            return nil
        }
        return decoded
    }
} 