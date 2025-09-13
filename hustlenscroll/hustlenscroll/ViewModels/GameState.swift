import Foundation
import SwiftUI
import AudioToolbox

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
    @Published var profileImage: String?
    @Published var hasStartup: Bool = false
    @Published var startupBalance: Double = 0
    @Published var startupRevenue: Double = 0
    @Published var startupExpenses: Double = 0
    @Published var creditCardBalance: Double = 0
    @Published var blackCardBalance: Double = 0
    @Published var platinumCardBalance: Double = 0
    @Published var familyTrustBalance: Double = 0
    @Published var creditLimit: Double = 5000
    @Published var transactions: [Transaction] = []
    @Published var businessTransactions: [Transaction] = []
    @Published var businessName: String = ""
    @Published var businessProfitLoss: Double = 0
    @Published var playerGoal: Goal?
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
    @Published var lastRecordedMonth: Date? = nil
    @Published var showingExitOpportunity: BusinessOpportunity? = nil
    @Published var currentMarketUpdate: MarketUpdate? = nil
    @Published var userPosts: [Post] = []
    @Published var pendingUserPosts: [Post] = []
    @Published var draftPost: (content: String, images: [String], opportunity: BusinessOpportunity?, investment: Asset?)? = nil
    // Feed refresh-based payday schedule
    @Published var refreshesSincePayday: Int = 0
    @Published var nextPaydayIn: Int = 3
    // Stage / theme
    @Published var hasLeveledUpToWealthStage: Bool = false
    @Published var prefersDarkModeAfterLevelUp: Bool = true
    
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
        self.userPosts = []
        self.transactions = []
        self.messages = []
        self.activeBusinesses = []
        self.cryptoPortfolio = CryptoPortfolio(assets: [])
        self.equityPortfolio = EquityPortfolio(assets: [])
        
        // Initialize with default role (Junior Developer)
        self.currentPlayer = Player(name: "", role: "Junior Developer")
        
        self.playerGoal = nil
        self.profile = nil
        self.profileImage = nil
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
            self.posts = decoded.posts
            self.userPosts = decoded.userPosts
            self.pendingUserPosts = decoded.pendingUserPosts ?? []
            self.profileImage = decoded.profileImage
            self.blackCardBalance = decoded.blackCardBalance
            self.platinumCardBalance = decoded.platinumCardBalance
            self.familyTrustBalance = decoded.familyTrustBalance
            self.refreshesSincePayday = decoded.refreshesSincePayday ?? 0
            self.nextPaydayIn = decoded.nextPaydayIn ?? Int.random(in: 3...6)
            self.hasLeveledUpToWealthStage = decoded.hasLeveledUpToWealthStage ?? false
            self.prefersDarkModeAfterLevelUp = decoded.prefersDarkModeAfterLevelUp ?? true
            
            // Clean up any duplicate messages
            removeDuplicateMessages()
            
            // Only add initial messages if we don't have any
            if messages.isEmpty {
                self.messages = initialMessages
            }
        } else {
            // Add initial messages for new game
            self.messages = initialMessages
        }
        
        // Ensure profile exists
        if profile == nil && !currentPlayer.name.isEmpty {
            profile = Profile(
                name: currentPlayer.name,
                role: currentPlayer.role,
                goal: playerGoal ?? .retirement
            )
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
        
        // Add initial filler posts if no posts exist
        if self.posts.isEmpty {
            self.posts = SampleContent.generateFillerPosts(count: 3)
        }
        if nextPaydayIn <= 0 { nextPaydayIn = Int.random(in: 3...6) }
        
        // Force a save to ensure everything is persisted
        saveState()
    }
    
    private func removeDuplicateMessages() {
        var seen = Set<String>()
        messages = messages.filter { message in
            let key = "\(message.senderId)|\(message.timestamp)|\(message.content)"
            return seen.insert(key).inserted
        }
        objectWillChange.send()
    }
    
    func saveState() {
        let state = SavedGameState(
            events: events,
            eventLog: eventLog,
            posts: posts,
            userPosts: userPosts,
            pendingUserPosts: pendingUserPosts,
            player: currentPlayer,
            goal: playerGoal,
            profileImage: profileImage,
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
            currentMarketUpdate: currentMarketUpdate,
            blackCardBalance: blackCardBalance,
            platinumCardBalance: platinumCardBalance,
            familyTrustBalance: familyTrustBalance,
            refreshesSincePayday: refreshesSincePayday,
            nextPaydayIn: nextPaydayIn,
            hasLeveledUpToWealthStage: hasLeveledUpToWealthStage,
            prefersDarkModeAfterLevelUp: prefersDarkModeAfterLevelUp
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
        let defaultRole = Role.getRole(byTitle: "Junior Developer")!
        currentPlayer = Player(name: "", role: defaultRole.title)
        
        playerGoal = nil
        profile = nil
        profileImage = nil
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
        messages = initialMessages
        posts = SampleContent.generateFillerPosts(count: 3)
        userPosts = []
        pendingUserPosts = []
        lastRecordedMonth = nil
        showingExitOpportunity = nil
        currentMarketUpdate = nil
        blackCardBalance = 0
        platinumCardBalance = 0
        familyTrustBalance = 0
        
        saveState()
    }
    
    func advanceTurn() {
        // Record all monthly transactions
        let dividend = activeBusinesses.reduce(0.0) { $0 + ($1.monthlyCashflow * ($1.revenueShare / 100.0)) }
        recordMonthlyTransactions(monthlyDividend: dividend)
        
        // Get role details
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return }
        
        // Update bank balance with income
        currentPlayer.bankBalance += role.monthlySalary
        currentPlayer.bankBalance += dividend
        
        // Update bank balance with expenses
        currentPlayer.bankBalance -= role.monthlyExpenses
        
        // Update credit card balance with minimum payment
        creditCardBalance += role.expenses.creditCard
        
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
        if Role.getRole(byTitle: player.role) != nil {
            self.profile = Profile(
                name: player.name,
                role: player.role,
                goal: playerGoal ?? .retirement
            )
            saveState()
        }
    }
    
    func updateProfile(name: String, role: String, goal: Goal) {
        if Role.getRole(byTitle: role) != nil {
            self.profile = Profile(name: name, role: role, goal: goal)
            saveState()
        }
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
    
    func recordMonthlyTransactions(for date: Date = Date(), monthlyDividend: Double? = nil) {
        let calendar = Calendar.current
        let currentMonth = calendar.startOfMonth(from: date)
        
        // Check if we've already recorded transactions for this month
        if let lastMonth = lastRecordedMonth,
           calendar.isDate(lastMonth, equalTo: currentMonth, toGranularity: .month) {
            return
        }
        
        // Get role details
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return }
        
        // Record salary income
        transactions.append(Transaction(
            date: currentMonth,
            description: "Monthly Salary",
            amount: role.monthlySalary,
            isIncome: true
        ))
        
        // Record monthly dividend as a single line item
        let dividendTotal = monthlyDividend ?? activeBusinesses.reduce(0.0) { $0 + ($1.monthlyCashflow * ($1.revenueShare / 100.0)) }
        if dividendTotal > 0 {
            transactions.append(Transaction(
                date: currentMonth,
                description: "Monthly Dividend",
                amount: dividendTotal,
                isIncome: true
            ))
        }
        
        // Record expenses
        let expenses = role.expenses
        let expenseItems: [(String, Double)] = [
            ("Rent", expenses.rent),
            ("Cell & Internet", expenses.cellAndInternet),
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
        self.playerGoal = goal
        if let name = profile?.name {
            self.profile = Profile(
                name: name,
                role: currentPlayer.role,
                goal: goal
            )
        }
        saveState()
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
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return }
        canQuitJob = totalPassiveIncome > role.monthlyExpenses
    }
    
    func acceptOpportunity(_ opportunity: BusinessOpportunity) {
        // Process the opportunity acceptance
        activeBusinesses.append(opportunity)
        currentPlayer.activeBusinesses.append(opportunity.id.uuidString)
        hasStartup = true  // Set hasStartup to true when a business is added
        
        // Record the transaction
        let transaction = Transaction(
            date: Date(),
            description: "Started \(opportunity.title) (ID: \(opportunity.id.uuidString.prefix(8)))",
            amount: opportunity.setupCost,
            isIncome: false
        )
        transactions.append(transaction)
        
        // Create a post about the purchase (journal entry)
        let purchasePost = Post(
            author: currentPlayer.name,
            role: currentPlayer.role,
            content: "Just acquired \(opportunity.title)! Initial investment: $\(Int(opportunity.setupCost)). New monthly cash flow: $\(Int(opportunity.monthlyCashflow)). 🚀",
            timestamp: Date(),
            isSponsored: false
        )
        addPost(purchasePost)

        saveState()
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
    
    private func getSymbolForTitle(_ title: String) -> String {
        if title.lowercased().contains("ai") && title.lowercased().contains("health") {
            return "AI Health Tech"
        } else if title.lowercased().contains("event") && title.lowercased().contains("booking") {
            return "Event Platform"
        } else if title.lowercased().contains("fitness") && title.lowercased().contains("app") {
            return "Fitness App"
        } else if title.lowercased().contains("developer") || title.lowercased().contains("dev") {
            return "Dev Tool"
        }
        return title
    }
    
    // Add a method to add a message to a thread
    func addMessageToThread(senderId: String, message: Message) {
        // Check if this exact message already exists
        let isDuplicate = messages.contains { existingMessage in
            existingMessage.senderId == message.senderId &&
            existingMessage.content == message.content &&
            abs(existingMessage.timestamp.timeIntervalSince(message.timestamp)) < 1.0  // Within 1 second
        }
        
        // Only add if not a duplicate
        if !isDuplicate {
            messages.append(message)
            // Trigger feedback for important inbound messages (accountant or opportunity-linked)
            if message.senderName != currentPlayer.name && (message.senderRole == "Accountant" || message.opportunity != nil) {
                triggerIncomingStartupOpportunityFeedback()
            }
            saveState()
            objectWillChange.send()
        }
    }
    
    // Update the handleOpportunityResponse method to use the thread
    func handleOpportunityResponse(message: Message, accepted: Bool, expired: Bool = false) {
        print("\n💬 OPPORTUNITY RESPONSE LOG:")
        print("----------------------------------------")
        print("Initial Message Details:")
        print("  - Original Message ID: \(message.id)")
        print("  - Original Sender: \(message.senderName)")
        print("  - Action: \(accepted ? "Accepting" : expired ? "Expired" : "Rejecting") opportunity")
        
        // Update the original message's status first
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].opportunityStatus = accepted ? .accepted : .rejected
            print("\nUpdated Original Message Status:")
            print("  - Status changed to: \(accepted ? "Accepted" : "Rejected")")
        }
        
        // Use the original message's timestamp as the base
        let baseTimestamp = message.timestamp
        
        if expired {
            // For expired opportunities, only add broker's message
            let brokerResponseId = UUID()
            // Find the latest timestamp already in this thread
            let latestThreadTime = messages
                .filter { ($0.opportunityId ?? $0.id) == message.id }
                .map { $0.timestamp }
                .max() ?? baseTimestamp
            // Choose a strictly later timestamp (by a small epsilon)
            let brokerTimestamp = max(latestThreadTime.addingTimeInterval(0.001), Date())
            let brokerMessage = Message(
                id: brokerResponseId,
                senderId: message.senderId,
                senderName: message.senderName,
                senderRole: message.senderRole,
                timestamp: brokerTimestamp,
                content: "I'm sorry, but you're too late. Someone has submitted an offer and it was accepted.",
                isRead: false,
                opportunityId: message.id
            )
            messages.append(brokerMessage)
            print("\nAdded Expiry Message:")
            print("  - Message ID: \(brokerResponseId)")
            print("  - Content: \(brokerMessage.content)")
        } else {
            // Create user's response message with unique ID and strictly increasing timestamp
            let userResponseId = UUID()
            // Latest timestamp in this thread
            let latestThreadTime = messages
                .filter { ($0.opportunityId ?? $0.id) == message.id }
                .map { $0.timestamp }
                .max() ?? baseTimestamp
            let userTimestamp = max(latestThreadTime.addingTimeInterval(0.001), Date())
            let userMessage = Message(
                id: userResponseId,
                senderId: message.senderId,  // Use the same senderId as the original message
                senderName: currentPlayer.name,
                senderRole: currentPlayer.role,
                timestamp: userTimestamp,
                content: accepted ? 
                    BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.userAcceptanceMessages) :
                    BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.userRejectionMessages),
                isRead: true,
                opportunityId: message.id  // Link to original message
            )
            
            // Add user message to messages array
            messages.append(userMessage)
            print("\nAdded User Response Message:")
            print("  - Message ID: \(userResponseId)")
            print("  - Content: \(userMessage.content)")
            
            // Create broker's response with unique ID (2 minutes after original)
            let brokerResponseId = UUID()
            // Broker follows immediately after the user reply (small epsilon)
            let brokerTimestamp = userTimestamp.addingTimeInterval(0.001)
            let brokerMessage = Message(
                id: brokerResponseId,
                senderId: message.senderId,  // Keep original sender's ID for thread
                senderName: message.senderName,
                senderRole: message.senderRole,
                timestamp: brokerTimestamp,
                content: accepted ?
                    BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.brokerFollowUpMessages) :
                    BusinessResponseMessages.getRandomMessage(BusinessResponseMessages.brokerRejectionResponses),
                isRead: false,
                opportunityId: message.id  // Link to original message
            )
            
            // Add broker message to messages array
            messages.append(brokerMessage)
            print("\nAdded Broker Response Message:")
            print("  - Message ID: \(brokerResponseId)")
            print("  - Content: \(brokerMessage.content)")
            
            // Only process business acceptance if the response was "accepted"
            if accepted && message.opportunity?.type == .startup {
                // We no longer create the business here since it's handled in BusinessPurchaseView
            }
        }
        
        // Force UI update and save state
        objectWillChange.send()
        saveState()
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
        case baby
        case cryptoUpdate
        case equityUpdate
        case cryptoDM
        case startupExit
        
        enum OpportunitySize {
            case small
            case large
        }
        
        static func random() -> DayType {
            let random = Double.random(in: 0...100)
            var cumulativeProbability = 0.0
            
            // Baby: 1/360 = ~0.28%
            cumulativeProbability += 0.28
            if random < cumulativeProbability {
                return .baby
            }
            
            // Unwanted expenses: 12/360 = ~3.33%
            cumulativeProbability += 3.33
            if random < cumulativeProbability {
                return .expense
            }
            
            // Paydays: 24/360 = ~6.67%
            cumulativeProbability += 6.67
            if random < cumulativeProbability {
                return .payday
            }
            
            // Startup opportunities: 24/360 = ~6.67%
            cumulativeProbability += 6.67
            if random < cumulativeProbability {
                let isLarge = Bool.random()
                return .opportunity(isLarge ? .large : .small)
            }
            
            // Startup updates and exits: 40/360 = ~11.11%
            cumulativeProbability += 11.11
            if random < cumulativeProbability {
                // 50% chance for exit check, 50% chance for update
                return Bool.random() ? .startupExit : .equityUpdate
            }
            
            // Equity updates: 24/360 = ~6.67%
            cumulativeProbability += 6.67
            if random < cumulativeProbability {
                return .equityUpdate
            }
            
            // Crypto updates: 40/360 = ~11.11%
            cumulativeProbability += 11.11
            if random < cumulativeProbability {
                return .cryptoUpdate
            }
            
            // Crypto DMs: 48/360 = ~13.33%
            cumulativeProbability += 13.33
            if random < cumulativeProbability {
                return .cryptoDM
            }
            
            // If none of the above, default to small opportunity
            return .opportunity(.small)
        }
    }
    
    // Add these functions to GameState
    func advanceDay() {
        // Start a fresh feed each refresh
        posts = []
        // Expire any pending startup offers (no response yet)
        expirePendingStartupOffers()

        // Always generate a market update (alternating between crypto, equity, and startup)
        let updateType = Int.random(in: 0...2)
        switch updateType {
        case 0:
            handleCryptoUpdate()
        case 1:
            handleEquityUpdate()
        case 2:
            handleBusinessUpdate()
        default:
            break
        }

        // Insert 1–2 opportunities
        let opportunityCount = Int.random(in: 1...2)
        for _ in 0..<opportunityCount {
            generateOpportunity(size: Bool.random() ? .small : .large)
        }

        // Add filler posts (5–8) to make the feed feel alive
        let filler = SampleContent.generateFillerPosts(count: Int.random(in: 5...8))
        posts.append(contentsOf: filler)

        // Handle other daily events (these may also add posts/messages)
        // Payday is now scheduled by refresh counter below
        let dayType = DayType.random()
        switch dayType {
        case .expense:
            generateUnexpectedExpense()
        case .baby:
            handleBabyEvent()
        case .cryptoDM:
            handleCryptoDM()
        case .startupExit:
            checkStartupExitOpportunities()
        default:
            break
        }

        // Refresh-based payday scheduling
        refreshesSincePayday += 1
        if refreshesSincePayday >= nextPaydayIn {
            handlePayday()
            refreshesSincePayday = 0
            nextPaydayIn = Int.random(in: 3...6)
            // Level up if out of rat race and not already leveled up
            if isOutOfRatRace && !hasLeveledUpToWealthStage {
                hasLeveledUpToWealthStage = true
                // Send mentor + accountant onboarding messages
                let mentorMsg = Message(
                    senderId: "mentor",
                    senderName: "David Chen",
                    senderRole: "Startup Advisor",
                    timestamp: Date(),
                    content: "Congrats! You've left the rat race. Welcome to the Wealth Management stage. Focus on land, structures, and diversification.",
                    isRead: false
                )
                messages.append(mentorMsg)
                let accountantMsg = Message(
                    senderId: "accountant",
                    senderName: "Steven Johnson",
                    senderRole: "Accountant",
                    timestamp: Date(),
                    content: "Now that you're cashflow positive, we can optimize with Family Trust and Holding Companies. I'll send options shortly.",
                    isRead: false
                )
                messages.append(accountantMsg)
                triggerIncomingStartupOpportunityFeedback()
                saveState()
                objectWillChange.send()
            }
        }

        // Shuffle non-pending content to simulate a random feed
        var shuffled = posts
        shuffled.shuffle()

        // Show any user posts once at the top on next refresh
        if !pendingUserPosts.isEmpty {
            posts = pendingUserPosts + shuffled
            pendingUserPosts.removeAll()
        } else {
            posts = shuffled
        }

        saveState()
        objectWillChange.send()
    }

    private func expirePendingStartupOffers() {
        // For each startup opportunity message still pending, add an expiry follow-up
        let pending = messages.filter { $0.opportunity?.type == .startup && $0.opportunityStatus == .pending }
        guard !pending.isEmpty else { return }
        for original in pending {
            handleOpportunityResponse(message: original, accepted: false, expired: true)
        }
    }
    
    private func generateOpportunity(size: DayType.OpportunitySize) {
        // 30% chance for investment opportunity → feed only
        if Double.random(in: 0...1) < 0.3 {
            let (investment, message) = createInvestmentOpportunity()

            // Add to feed as post (no DM for investments)
            let priceText = String(format: "%.2f", investment.currentPrice)
            let post = Post(
                id: UUID(),
                author: message.senderName,
                role: message.senderRole,
                content: "🔥 Hot Investment: \(investment.name) (\(investment.symbol)) at $\(priceText)",
                timestamp: Date(),
                isSponsored: true,
                linkedInvestment: investment
            )
            posts.append(post)
            saveState()
            objectWillChange.send()
            return
        }

        // Filter opportunities by size (startup buys) → messages only
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
            revenueShare: opportunity.revenueShare,
            symbol: getSymbolForTitle(opportunity.title)
        )
        // Startup buy opportunities go to Messages only
        let startupMessage = Message(
            senderId: message.senderId,
            senderName: message.senderName,
            senderRole: message.senderRole,
            timestamp: Date(),
            content: message.content,
            opportunity: Opportunity(
                title: newOpportunity.title,
                description: newOpportunity.description,
                type: .startup,
                requiredInvestment: newOpportunity.setupCost,
                monthlyRevenue: newOpportunity.monthlyRevenue,
                monthlyExpenses: newOpportunity.monthlyExpenses,
                revenueShare: newOpportunity.revenueShare
            ),
            isRead: false
        )
        messages.append(startupMessage)
        triggerIncomingStartupOpportunityFeedback()
        saveState()
        objectWillChange.send()
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
        
        // Get role details for salary
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return }
        
        // Add salary to bank account
        currentPlayer.bankBalance += role.monthlySalary

        // Add monthly dividend (sum of user's share of cashflow from all owned businesses)
        let monthlyDividend = activeBusinesses.reduce(0.0) { partial, business in
            partial + (business.monthlyCashflow * (business.revenueShare / 100.0))
        }
        if monthlyDividend > 0 {
            currentPlayer.bankBalance += monthlyDividend
        }
        
        // Add message notification with explicit isRead = false
        let paydayMessage = Message(
            senderId: "BANK",
            senderName: "Quantum Bank",
            senderRole: "Payroll Department",
            timestamp: Date(),
            content: monthlyDividend > 0 ?
                "Your monthly salary of $\(Int(role.monthlySalary)) and your dividend of $\(Int(monthlyDividend)) (\(Int(activeBusinesses.reduce(0.0){$0 + ($1.revenueShare) }/Double(max(activeBusinesses.count,1))))% of business cashflow) have been deposited into your checking account." :
                "Your monthly salary of $\(Int(role.monthlySalary)) has been deposited into your checking account.",
            opportunity: nil,
            isRead: false
        )
        
        // Only add if not a duplicate
        if !messages.contains(where: { 
            $0.senderId == paydayMessage.senderId && 
            $0.timestamp == paydayMessage.timestamp &&
            $0.content == paydayMessage.content 
        }) {
            messages.append(paydayMessage)
            objectWillChange.send()
        }
        
        // Record transactions immediately for visibility in checking account
        transactions.append(Transaction(
            date: Date(),
            description: "Monthly Salary",
            amount: role.monthlySalary,
            isIncome: true
        ))
        if monthlyDividend > 0 {
            transactions.append(Transaction(
                date: Date(),
                description: "Monthly Dividend",
                amount: monthlyDividend,
                isIncome: true
            ))
        }
    }
    
    private func generateUnexpectedExpense() {
        // Get a random predefined expense
        let expense = UnexpectedExpense.predefinedExpenses.randomElement()!
        
        // Get the appropriate sender based on the expense category
        let sender = getSenderForExpense(expense)
        
        // Use current date for the message
        let expenseMessage = Message(
            senderId: sender.id,
            senderName: sender.name,
            senderRole: sender.role,
            timestamp: Date(),
            content: "\(expense.title): \(expense.description)\nAmount: $\(Int(expense.amount))",
            opportunity: nil,
            isRead: false
        )
        
        // Only add if not a duplicate
        if !messages.contains(where: { 
            $0.senderId == expenseMessage.senderId && 
            $0.timestamp == expenseMessage.timestamp &&
            $0.content == expenseMessage.content 
        }) {
            messages.append(expenseMessage)
            objectWillChange.send()
        }
        
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
    
    private func getSenderForExpense(_ expense: UnexpectedExpense) -> UnexpectedExpense.ExpenseSender {
        switch expense.category {
        case .personal:
            return UnexpectedExpense.expenseSenders[0] // Mom
        case .business:
            return UnexpectedExpense.expenseSenders[1] // Steven Johnson
        case .tech, .crypto:
            return UnexpectedExpense.expenseSenders[2] // Chloe S
        case .girlfriend:
            return UnexpectedExpense.expenseSenders[3] // Zoey
        }
    }
    
    // Update the unreadMessageCount to count actual unread messages
    var unreadMessageCount: Int {
        let unreadMessages = messages.filter { !$0.isRead && !$0.isArchived }
        return unreadMessages.count
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
    
    // Add this function to create an investment opportunity from a market update
    private func createInvestmentFromUpdate(_ update: MarketUpdate.Update) -> Asset? {
        let currentPrice = update.newPrice
        
        switch update.type {
        case .crypto:
            return Asset(
                symbol: update.symbol,
                name: getAssetName(for: update.symbol),
                quantity: 1.0,  // Placeholder quantity
                currentPrice: currentPrice,
                purchasePrice: currentPrice,
                type: .crypto
            )
        case .stock:
            return Asset(
                symbol: update.symbol,
                name: getAssetName(for: update.symbol),
                quantity: 1.0,  // Placeholder quantity
                currentPrice: currentPrice,
                purchasePrice: currentPrice,
                type: .stock
            )
        default:
            return nil
        }
    }

    // Update the applyMarketUpdate function
    func applyMarketUpdate(_ update: MarketUpdate) {
        currentMarketUpdate = update
        
        // Create investment opportunity if price dropped
        var linkedInvestment: Asset? = nil
        if let firstUpdate = update.updates.first,
           let asset = createInvestmentFromUpdate(firstUpdate) {
            // Only suggest investment if price dropped (buying opportunity)
            if firstUpdate.newPrice < getCurrentPrice(for: firstUpdate.symbol) {
                linkedInvestment = asset
            }
        }
        
        // Create the market update post
        let post = Post(
            author: "MarketWatch",
            role: "Market Analysis",
            content: update.updates.first?.message ?? "Market Update",  // Use the price change message directly
            timestamp: Date(),
            isSponsored: true,
            linkedOpportunity: nil,
            linkedInvestment: linkedInvestment,
            linkedMarketUpdate: update
        )
        posts.insert(post, at: 0)
        
        // Apply updates
        for updateItem in update.updates {
            switch updateItem.type {
            case .crypto:
                applyCryptoUpdate(symbol: updateItem.symbol, newPrice: updateItem.newPrice)
            case .stock:
                applyStockUpdate(symbol: updateItem.symbol, newPrice: updateItem.newPrice)
            case .startup:
                if let multiple = updateItem.newMultiple {
                    applyStartupUpdate(change: multiple)
                }
            }
        }
        
        saveState()
        objectWillChange.send()
    }
    
    private func applyCryptoUpdate(symbol: String, newPrice: Double) {
        if let index = cryptoPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = cryptoPortfolio.assets[index]
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
    
    private func applyStockUpdate(symbol: String, newPrice: Double) {
        if let index = equityPortfolio.assets.firstIndex(where: { $0.symbol == symbol }) {
            let asset = equityPortfolio.assets[index]
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
            // Only update businesses that match the market update's symbol
            if let update = currentMarketUpdate?.updates.first,
               business.symbol == update.symbol {
                // Apply the change directly instead of using a multiplier
                business.currentExitMultiple = change
                // Ensure multiple stays within reasonable bounds
                business.currentExitMultiple = max(1.0, min(business.currentExitMultiple, 20.0))
                activeBusinesses[i] = business
                
                // Check for exit opportunity immediately after a significant increase
                if business.currentExitMultiple >= business.potentialSaleMultiple * 1.2 {
                    checkStartupExitOpportunities()
                }
            }
        }
    }
    
    private func checkStartupExitOpportunities() {
        for business in activeBusinesses {
            if business.currentExitMultiple >= business.potentialSaleMultiple * 1.2 {  // Reduced from 1.5x to 1.2x
                // Present exit opportunity
                showingExitOpportunity = business
                
                // Create market update for the startup
                let update = MarketUpdate.Update(
                    symbol: business.symbol,
                    newPrice: 0.0,  // Use 0.0 instead of nil for newPrice
                    newMultiple: business.currentExitMultiple,
                    message: "🚀 Hot Exit Opportunity: \(business.title) valuation soars to $\(Int(business.currentExitValue)) (\(String(format: "%.1fx", business.currentExitMultiple)) annual cash flow)",
                    type: .startup  // Use .startup instead of .business
                )
                
                let marketUpdate = MarketUpdate(
                    title: "Startup Exit Opportunity",
                    description: "Hot exit opportunity for \(business.title)",
                    updates: [update]
                )
                
                // Create and insert the market update post
                let post = Post(
                    author: "Sarah Chen",
                    role: "M&A Advisor",
                    content: update.message,
                    timestamp: Date(),
                    isSponsored: true,
                    linkedMarketUpdate: marketUpdate
                )
                posts.insert(post, at: 0)
                break  // Only show one exit opportunity at a time
            }
        }
    }
    
    private func generateBusinessUpdateReason(multiplierChange: Double) -> String {
        let positiveReasons = [
            "strong market growth",
            "increased customer demand",
            "successful product launch",
            "new partnership announcement",
            "improved profit margins",
            "industry recognition",
            "positive market sentiment"
        ]
        
        let negativeReasons = [
            "market competition",
            "sector slowdown",
            "temporary setback",
            "market uncertainty",
            "industry challenges",
            "regulatory changes",
            "shifting market conditions"
        ]
        
        let reasons = multiplierChange >= 0 ? positiveReasons : negativeReasons
        return reasons.randomElement() ?? (multiplierChange >= 0 ? "positive market conditions" : "market conditions")
    }
    
    func sellBusiness(_ business: BusinessOpportunity) {
        let saleProceeds = business.currentExitValue * (business.revenueShare / 100.0)
        
        // Add proceeds to Family Trust or bank account based on role
        if currentPlayer.role == "Owner / Angel Investor" {
            familyTrustBalance += saleProceeds
        } else {
            currentPlayer.bankBalance += saleProceeds
        }
        
        // Remove business from active businesses
        activeBusinesses.removeAll { $0.id == business.id }
        
        // Record transaction
        transactions.append(Transaction(
            date: Date(),
            description: "Sale of \(business.title)" + (currentPlayer.role == "Owner / Angel Investor" ? " (to Family Trust)" : " (to Checking Account)"),
            amount: saleProceeds,
            isIncome: true
        ))
        
        // Create a post about the sale
        let post = Post(
            author: currentPlayer.name,
            role: currentPlayer.role,
            content: "Just sold \(business.title) for $\(Int(saleProceeds)) at \(String(format: "%.1f", business.currentExitMultiple))x annual cash flow! 🎉💰",
            timestamp: Date(),
            isSponsored: false
        )
        addPost(post)
        
        // Save state after modifying balances
        saveState()
        objectWillChange.send()
        
        // Add confirmation message
        let confirmationMessage = Message(
            senderId: "exit_advisor",
            senderName: "Michael Chen",
            senderRole: "Exit Advisor",
            timestamp: Date(),
            content: "Congratulations on the successful sale of \(business.title)! The proceeds of $\(Int(saleProceeds)) have been deposited into your \(currentPlayer.role == "Owner / Angel Investor" ? "Family Trust" : "Checking Account").",
            isRead: false
        )
        messages.append(confirmationMessage)
        
        saveState()
        objectWillChange.send()
    }
    
    func createManualMarketUpdate(title: String, description: String, updates: [(symbol: String, newPrice: Double, message: String)]) {
        let marketUpdates = updates.map { update in
            MarketUpdate.Update(
                symbol: update.symbol,
                newPrice: update.newPrice,
                newMultiple: nil,
                message: update.message,
                type: update.symbol == "BTC" ? .crypto : .stock
            )
        }
        
        let marketUpdate = MarketUpdate(
            title: title,
            description: description,
            updates: marketUpdates
        )
        
        applyMarketUpdate(marketUpdate)
    }
    
    func addPost(_ post: Post) {
        // Normalize author to current handle when it's the user's post
        var resolvedPost = post
        if post.author == currentPlayer.name || post.author == profile?.name || post.author == currentPlayer.handle {
            if let h = currentPlayer.handle, !h.isEmpty {
                let display = h.hasPrefix("@") ? h : "@\(h)"
                resolvedPost = Post(
                    id: post.id,
                    author: display,
                    role: post.role,
                    content: post.content,
                    timestamp: post.timestamp,
                    isSponsored: post.isSponsored,
                    linkedOpportunity: post.linkedOpportunity,
                    linkedInvestment: post.linkedInvestment,
                    linkedMarketUpdate: post.linkedMarketUpdate,
                    images: post.images,
                    isAutoGenerated: post.isAutoGenerated
                )
            }
        }
        // Always add to profile
        userPosts.insert(resolvedPost, at: 0)
        // Queue for one-time appearance in the next feed refresh
        pendingUserPosts.append(resolvedPost)
        saveState()
        objectWillChange.send()
    }
    
    func createAutoGeneratedPost(from opportunity: BusinessOpportunity) {
        guard let socialContent = opportunity.socialPostContent else { return }
        
        // Instead of creating the post directly, set the draft post
        draftPost = (
            content: socialContent.defaultText,
            images: socialContent.images,
            opportunity: opportunity,
            investment: nil
        )
        
        // Post a notification to show the draft view
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowDraftPost"),
            object: nil
        )
    }
    
    func createAutoGeneratedPost(for investment: Asset, action: String) {
        let content: String
        if action == "buy" {
            content = "Just invested in \(investment.name) (\(investment.symbol)) 📈"
        } else {
            content = "Sold my position in \(investment.name) (\(investment.symbol)) 💰"
        }
        
        // Set the draft post
        draftPost = (
            content: content,
            images: [],
            opportunity: nil,
            investment: investment
        )
        
        // Post a notification to show the draft view
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowDraftPost"),
            object: nil
        )
    }
    
    func createExpensePost(expense: UnexpectedExpense) {
        let content = "Just got hit with an unexpected expense: \(expense.title) for $\(String(format: "%.2f", expense.amount)) 😓"
        
        // Set the draft post
        draftPost = (
            content: content,
            images: [],
            opportunity: nil,
            investment: nil
        )
        
        // Post a notification to show the draft view
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowDraftPost"),
            object: nil
        )
    }
    
    // Add new function to get documents directory
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Add function to save image to file system
    private func saveImageToFile(_ imageData: Data) -> String {
        let filename = UUID().uuidString + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return ""
        }
    }
    
    // Add function to load image from file system
    private func loadImageFromFile(_ filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    // Update profile image handling
    func updateProfileImage(_ imageData: Data) {
        let filename = saveImageToFile(imageData)
        profileImage = filename
        saveState()
        objectWillChange.send()
    }
    
    // Update get profile image function
    func getProfileImage() -> UIImage? {
        guard let filename = profileImage else { return nil }
        return loadImageFromFile(filename)
    }
    
    var monthlyIncome: Double {
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return 0 }
        var income = role.monthlySalary
        
        // Add user's ownership share of all active businesses (treated as dividends)
        let ownershipDividend = activeBusinesses.reduce(0.0) { partial, business in
            partial + (business.monthlyCashflow * (business.revenueShare / 100.0))
        }
        income += ownershipDividend
        
        return income
    }
    
    var monthlyExpenses: Double {
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return 0 }
        var expenses = role.monthlyExpenses
        
        // Add child expenses
        expenses += Double(currentPlayer.children) * role.expenses.perChild
        
        // Add credit card minimum payment (3% of balance)
        if creditCardBalance > 0 {
            expenses += creditCardBalance * 0.03
        }
        
        return expenses
    }
    
    var monthlyCashflow: Double {
        monthlyIncome - monthlyExpenses
    }
    
    var isOutOfRatRace: Bool {
        monthlyIncome > monthlyExpenses
    }
    
    func setRole(_ role: String) {
        if Role.getRole(byTitle: role) != nil {
            currentPlayer.role = role
            saveState()
        }
    }
    
    func calculateMonthlyIncome() -> Double {
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return 0 }
        var income = role.monthlySalary
        
        // Add business income
        income += totalMonthlyBusinessIncome
        
        // Add investment returns (5% annual return = ~0.4% monthly)
        let monthlyReturnRate = 0.004 // 0.4% monthly return
        
        let cryptoValue = cryptoPortfolio.assets.reduce(0.0) { $0 + ($1.currentPrice * $1.quantity) }
        let equityValue = equityPortfolio.assets.reduce(0.0) { $0 + ($1.currentPrice * $1.quantity) }
        
        let cryptoReturns = cryptoValue * monthlyReturnRate
        let equityReturns = equityValue * monthlyReturnRate
        
        income += cryptoReturns + equityReturns
        
        return income
    }
    
    func calculateMonthlyExpenses() -> Double {
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return 0 }
        var expenses = role.monthlyExpenses
        expenses += Double(currentPlayer.children) * role.expenses.perChild
        return expenses
    }
    
    func canAffordOpportunity(_ opportunity: BusinessOpportunity) -> Bool {
        let availableFunds = currentPlayer.bankBalance + currentPlayer.savingsBalance
        return availableFunds >= opportunity.setupCost
    }
    
    func markThreadAsRead(senderId: String) {
        var updatedMessages = messages
        var messageCount = 0
        
        // Mark all messages in the thread as read
        for index in updatedMessages.indices {
            if updatedMessages[index].senderId == senderId {
                if !updatedMessages[index].isRead {
                    updatedMessages[index].isRead = true
                    messageCount += 1
                }
            }
        }
        
        // Only update if we actually changed something
        if messageCount > 0 {
            messages = updatedMessages
            objectWillChange.send()
            saveState()
        }
    }
    
    private func handleBabyEvent() {
        // Only proceed if player can have more children (max 3)
        guard currentPlayer.children < 3 else { return }
        
        // Get role details for child expenses
        guard let role = Role.getRole(byTitle: currentPlayer.role) else { return }
        
        // Add a child
        currentPlayer.children += 1
        
        // Record the new monthly expense transaction
        transactions.append(Transaction(
            date: Date(),
            description: "New Monthly Child Expense",
            amount: role.expenses.perChild,
            isIncome: false
        ))
        
        // Create announcement message
        let babyMessage = Message(
            senderId: "girlfriend",
            senderName: "Zoey",
            senderRole: "Family",
            timestamp: Date(),
            content: """
            🎉 Honey... I have something to tell you... We're having a baby! 🍼
            
            Monthly child expenses: $\(Int(role.expenses.perChild))
            Total monthly child expenses: $\(Int(role.expenses.perChild * Double(currentPlayer.children)))
            Total children: \(currentPlayer.children)
            
            This expense has been added to our monthly expenses.
            """,
            isRead: false
        )
        
        // Add message
        messages.append(babyMessage)
        
        // Create social post about the baby
        let post = Post(
            id: UUID(),
            author: currentPlayer.name,
            role: currentPlayer.role,
            content: "🍼 Exciting news! @Zoey and I are having a baby! #BabyJoy #NewParent",
            timestamp: Date(),
            isSponsored: false
        )
        posts.insert(post, at: 0)
        
        // Save state and update UI
        saveState()
        objectWillChange.send()
    }
    
    private func handleCryptoUpdate() {
        // Generate random price change (-20% to +20%)
        let priceChange = Double.random(in: -0.20...0.20)
        
        // Select a random crypto asset
        let cryptoSymbols = ["BTC", "ETH", "SOL", "DOGE"]
        let symbol = cryptoSymbols.randomElement() ?? "BTC"
        
        // Create market update
        let update = MarketUpdate(
            title: "Crypto Market Update",
            description: "Market volatility triggers significant price movement",
            updates: [
                MarketUpdate.Update(
                    symbol: symbol,
                    newPrice: getCurrentPrice(for: symbol) * (1 + priceChange),
                    newMultiple: nil,
                    message: getPriceChangeMessage(symbol: symbol, change: priceChange),
                    type: .crypto
                )
            ]
        )
        
        applyMarketUpdate(update)
    }
    
    private func handleEquityUpdate() {
        // Generate random price change (-10% to +10%)
        let priceChange = Double.random(in: -0.10...0.10)
        
        // Select a random stock
        let stockSymbols = ["AAPL", "MSFT", "GOOGL", "AMZN", "NVDA"]
        let symbol = stockSymbols.randomElement() ?? "AAPL"
        
        // Create market update
        let update = MarketUpdate(
            title: "Stock Market Update",
            description: "Market conditions affect stock prices",
            updates: [
                MarketUpdate.Update(
                    symbol: symbol,
                    newPrice: getCurrentPrice(for: symbol) * (1 + priceChange),
                    newMultiple: nil,
                    message: getPriceChangeMessage(symbol: symbol, change: priceChange),
                    type: .stock
                )
            ]
        )
        
        applyMarketUpdate(update)
    }
    
    private func handleCryptoDM() {
        // Convert crypto DM into a feed investment post instead of a DM
        let cryptoSymbols = ["BTC", "ETH", "SOL", "DOGE"]
        let symbol = cryptoSymbols.randomElement() ?? "BTC"

        let analyst = Bool.random() ? "Alex Chen" : "Sarah Kim"
        let investment = Asset(
            symbol: symbol,
            name: getAssetName(for: symbol),
            quantity: 0,
            currentPrice: getCurrentPrice(for: symbol),
            purchasePrice: getCurrentPrice(for: symbol),
            type: .crypto
        )

        let priceText = String(format: "%.2f", investment.currentPrice)
        let post = Post(
            id: UUID(),
            author: analyst,
            role: "Crypto Market Analyst",
            content: "\(generateCryptoAdvice(for: symbol)) Current price for \(investment.name) (\(investment.symbol)) is $\(priceText).",
            timestamp: Date(),
            isSponsored: true,
            linkedInvestment: investment
        )

        posts.insert(post, at: 0)
        saveState()
        objectWillChange.send()
    }

    // MARK: - Notifications / Feedback
    private func triggerIncomingStartupOpportunityFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1007)
    }
    
    private func getCurrentPrice(for symbol: String) -> Double {
        // Return current price if asset exists in portfolio
        if let asset = cryptoPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return asset.currentPrice
        }
        if let asset = equityPortfolio.assets.first(where: { $0.symbol == symbol }) {
            return asset.currentPrice
        }
        
        // Return default prices for known assets
        switch symbol {
        case "BTC": return 52000.0
        case "ETH": return 3200.0
        case "SOL": return 120.0
        case "DOGE": return 0.15
        case "AAPL": return 190.0
        case "MSFT": return 420.0
        case "GOOGL": return 150.0
        case "AMZN": return 170.0
        case "NVDA": return 850.0
        default: return 100.0
        }
    }
    
    private func getPriceChangeMessage(symbol: String, change: Double) -> String {
        let percentChange = change * 100
        let direction = change > 0 ? "up" : "down"
        let emoji = change > 0 ? "📈" : "📉"
        
        return "\(getAssetName(for: symbol)) (\(symbol)) is \(direction) \(String(format: "%.1f", abs(percentChange)))% \(emoji)"
    }
    
    private func generateCryptoAdvice(for symbol: String) -> String {
        let messages = [
            "Technical analysis suggests a potential breakout for \(symbol). Worth considering an entry point here.",
            "Market sentiment for \(symbol) is turning positive. This could be a good opportunity.",
            "Institutional interest in \(symbol) is growing. Might be worth adding to your portfolio.",
            "Recent developments in \(symbol) look promising. Consider taking a position."
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    private func getAssetName(for symbol: String) -> String {
        switch symbol {
        case "BTC": return "Bitcoin"
        case "ETH": return "Ethereum"
        case "SOL": return "Solana"
        case "DOGE": return "Dogecoin"
        case "AAPL": return "Apple Inc"
        case "MSFT": return "Microsoft Corporation"
        case "GOOGL": return "Alphabet Inc"
        case "AMZN": return "Amazon.com Inc"
        case "NVDA": return "NVIDIA Corporation"
        default: return symbol
        }
    }
    
    private func handleBusinessUpdate() {
        // Only proceed if there are active businesses
        guard !activeBusinesses.isEmpty else { return }
        
        // Select a random business from active businesses
        guard let business = activeBusinesses.randomElement() else { return }
        
        // Calculate a new random multiple between 2x and 14x
        let newMultiple = Double.random(in: 2.0...14.0)
        
        // Create market update
        let update = MarketUpdate.Update(
            symbol: business.symbol,
            newPrice: 0.0,  // Use 0.0 instead of nil
            newMultiple: newMultiple,
            message: generateBusinessUpdateMessage(business: business, newMultiple: newMultiple),
            type: .startup  // Use .startup instead of .business
        )
        
        let marketUpdate = MarketUpdate(
            title: "Business Market Update",
            description: "Latest valuations for \(business.title)",
            updates: [update]
        )
        
        // Update the business's exit multiple with safety bounds
        if let index = activeBusinesses.firstIndex(where: { $0.id == business.id }) {
            activeBusinesses[index].currentExitMultiple = max(1.0, min(newMultiple, 20.0))
        }
        
        // Save state after modifying business values
        saveState()
        objectWillChange.send()
        
        // Create and add the post
        let post = Post(
            author: "Market Watch",
            role: "Market Analysis",
            content: "Business Market Update",
            timestamp: Date(),
            isSponsored: true,
            linkedMarketUpdate: marketUpdate
        )
        // Insert directly into feed (do not add to user's profile)
        posts.insert(post, at: 0)
    }
    
    private func generateBusinessUpdateMessage(business: BusinessOpportunity, newMultiple: Double) -> String {
        let valueChange = newMultiple >= business.currentExitMultiple ? "rises" : "drops"
        let emoji = newMultiple >= business.currentExitMultiple ? "📈" : "📉"
        let reason = generateBusinessUpdateReason(multiplierChange: (newMultiple - business.currentExitMultiple) / business.currentExitMultiple)
        
        return "\(business.title) valuation \(valueChange) to \(String(format: "%.1f", newMultiple))x annual cash flow due to \(reason) \(emoji)"
    }
    
    func payCredit(amount: Double, cardType: AccountType) {
        switch cardType {
        case .creditCard:
            guard amount <= creditCardBalance else { return }
            creditCardBalance -= amount
        case .blackCard:
            guard amount <= blackCardBalance else { return }
            blackCardBalance -= amount
        case .platinumCard:
            guard amount <= platinumCardBalance else { return }
            platinumCardBalance -= amount
        default:
            return
        }
        
        currentPlayer.bankBalance -= amount
        
        transactions.append(Transaction(
            date: Date(),
            description: "Payment to \(cardType.title)",
            amount: amount,
            isIncome: false
        ))
        
        saveState()
        objectWillChange.send()
    }
}

// Structure to represent saved game data
struct SavedGameState: Codable {
    let events: [GameEvent]
    let eventLog: [String]
    let posts: [Post]
    let userPosts: [Post]
    let pendingUserPosts: [Post]?
    let player: Player
    let goal: Goal?
    let profileImage: String?
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
    let blackCardBalance: Double
    let platinumCardBalance: Double
    let familyTrustBalance: Double
    let refreshesSincePayday: Int?
    let nextPaydayIn: Int?
    let hasLeveledUpToWealthStage: Bool?
    let prefersDarkModeAfterLevelUp: Bool?
} 
