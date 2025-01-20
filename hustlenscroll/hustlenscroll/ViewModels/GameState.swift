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
    
    private func createInitialMentorMessages() -> [Message] {
        return [
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: Date().addingTimeInterval(-300),
                content: "👋 Hey there! I'm David, and I'll be your mentor on your journey from employee to entrepreneur. I've helped dozens of developers like you build successful businesses.",
                opportunity: nil,
                isRead: false
            ),
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: Date().addingTimeInterval(-240),
                content: "Your goal is to achieve financial independence. You can do this in two phases:\n\n1️⃣ First, build enough side income to quit your job\n2️⃣ Then, grow your investments to achieve your ultimate goal",
                opportunity: nil,
                isRead: false
            ),
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: Date().addingTimeInterval(-180),
                content: "You can quit your job when your monthly passive income exceeds your monthly expenses. This can come from:\n\n📱 Side projects\n💼 Consulting work\n📈 Investment returns",
                opportunity: nil,
                isRead: false
            ),
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: Date().addingTimeInterval(-120),
                content: "To get started:\n\n1. Pull down the Feed to refresh and see opportunities\n2. Look for both small and large opportunities\n3. Check your Messages for details when something interests you\n4. Track your progress in the Bank tab",
                opportunity: nil,
                isRead: false
            ),
            Message(
                senderId: "mentor",
                senderName: "David Chen",
                senderRole: "Startup Advisor",
                timestamp: Date().addingTimeInterval(-60),
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
            
            // Only add initial messages if we don't have any
            if messages.isEmpty {
                self.messages = createInitialMentorMessages()
            }
        } else {
            // Add initial messages for new game
            self.messages = createInitialMentorMessages()
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
        self.posts = SampleContent.generateFillerPosts(count: 50)
        
        // Force a save to ensure everything is persisted
        saveState()
    }
    
    func saveState() {
        let state = SavedGameState(
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
            lastRecordedMonth: lastRecordedMonth
        )
        
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: "gameState")
            UserDefaults.standard.synchronize()  // Force immediate write
        }
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
        
        // Add initial messages from mentor
        messages = createInitialMentorMessages()
        
        // Add initial filler posts
        posts = SampleContent.generateFillerPosts(count: 50)
        
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
        let currentMonth = calendar.startOfMonth(for: date)
        
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
                var updatedMessage = message
                updatedMessage.isRead = true
                messages[index] = updatedMessage
                saveState()  // Save the game state after marking message as read
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
            
            // Add confirmation message
            let confirmationMessage = Message(
                id: UUID(),
                senderId: "SYSTEM",
                senderName: "System",
                senderRole: "Notification",
                timestamp: Date(),
                content: "Investment confirmed! You now own \(opportunity.revenueShare)% of \(opportunity.title). Your monthly share of the cash flow will be $\(Int(opportunity.monthlyCashflow * (opportunity.revenueShare / 100.0))).",
                opportunity: nil,
                isRead: false
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
            var updatedMessage = message
            updatedMessage.isRead = true
            updatedMessage.opportunityStatus = accepted ? .accepted : .rejected
            messages[index] = updatedMessage
        }
        
        // Create and add response message
        let responseMessage = Message(
            id: UUID(),
            senderId: message.senderId,
            senderName: message.senderName,
            senderRole: message.senderRole,
            timestamp: Date(),
            content: accepted ? "Great choice! Let's get started. I'll send you more details shortly." : SampleContent.getRandomRejectionResponse(),
            opportunity: nil,
            isRead: false
        )
        messages.append(responseMessage)
        
        // Save state after adding response message
        saveState()
        
        if accepted {
            switch opportunity.type {
            case .investment:
                // Find the matching investment in the posts based on the opportunity title
                if let post = posts.first(where: { 
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
                    opportunityType: convertOpportunityType(opportunity.type),
                    monthlyRevenue: opportunity.monthlyRevenue ?? 0,
                    monthlyExpenses: opportunity.monthlyExpenses ?? 0,
                    setupCost: opportunity.requiredInvestment ?? 0,
                    potentialSaleMultiple: 3.0,
                    revenueShare: opportunity.revenueShare ?? 100.0
                )
                
                // Process the opportunity acceptance
                acceptOpportunity(businessOpp)
            }
        }
        
        objectWillChange.send()
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
        let newPosts = SampleContent.generateFillerPosts(count: Int.random(in: 3...7))
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
        if posts.count > 1000 {
            posts = Array(posts.prefix(1000))
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
            nextMonth = calendar.startOfMonth(for: Date())
        }
        
        // Add salary to bank account
        currentPlayer.bankBalance += currentPlayer.monthlySalary
        
        // Add revenue share from businesses
        for business in activeBusinesses {
            let revenueShare = business.monthlyCashflow * (business.revenueShare / 100.0)
            currentPlayer.bankBalance += revenueShare
        }
        
        // Add message notification
        messages.append(Message(
            senderId: "BANK",
            senderName: "Quantum Bank",
            senderRole: "Payroll Department",
            timestamp: nextMonth,
            content: "Your monthly salary of $\(Int(currentPlayer.monthlySalary)) has been deposited into your account.",
            opportunity: nil
        ))
        
        // Record transactions for the next month
        recordMonthlyTransactions(for: nextMonth)
    }
    
    private func generateUnexpectedExpense() {
        // Get a random predefined expense
        let expense = UnexpectedExpense.predefinedExpenses.randomElement()!
        
        // Get current month
        let calendar = Calendar.current
        let currentMonth = lastRecordedMonth ?? calendar.startOfMonth(for: Date())
        
        // Add message notification
        messages.append(Message(
            senderId: "EXPENSE",
            senderName: "Life Happens",
            senderRole: "Expense Alert",
            timestamp: currentMonth,
            content: "\(expense.title): \(expense.description)\nAmount: $\(Int(expense.amount))",
            opportunity: nil
        ))
        
        // Deduct from bank balance
        currentPlayer.bankBalance -= expense.amount
        
        // Record transaction
        transactions.append(Transaction(
            date: currentMonth,
            description: expense.title,
            amount: expense.amount,
            isIncome: false
        ))
    }
    
    // Update the unreadMessageCount to only count unread active messages
    var unreadMessageCount: Int {
        let count = activeMessages.filter { !$0.isRead }.count
        return count
    }
    
    // Add this computed property to filter out archived messages
    var activeMessages: [Message] {
        messages.filter { !$0.isArchived }
    }
    
    func archiveMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            var updatedMessage = message
            updatedMessage.isArchived = true
            updatedMessage.isRead = true  // Mark archived messages as read
            messages[index] = updatedMessage
            saveState()
            objectWillChange.send()
        }
    }
}

// Structure to represent saved game data
struct SavedGameState: Codable {
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
} 