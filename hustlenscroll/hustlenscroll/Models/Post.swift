import Foundation

struct Post: Identifiable {
    let id: UUID = UUID()
    let userHandle: String
    let body: String
    let timestamp: Date = Date()
    let isGameEvent: Bool
    
    static let fillerPosts = [
        Post(userHandle: "@techBro", body: "Just deployed my first blockchain app! 🚀 #Web3", isGameEvent: false),
        Post(userHandle: "@codeCrafter", body: "Why do programmers prefer dark mode? Because light attracts bugs! 😅", isGameEvent: false),
        Post(userHandle: "@startupGuru", body: "Remember: failing fast is just another way of saying 'learning quickly' 💡", isGameEvent: false),
        Post(userHandle: "@devLife", body: "Coffee.exe has stopped working. Please restart programmer.", isGameEvent: false),
        Post(userHandle: "@techNews", body: "New JavaScript framework just dropped! Time to rewrite everything! 🔄", isGameEvent: false),
        Post(userHandle: "@productPerson", body: "Hot take: JIRA tickets are just fancy todo lists 📝", isGameEvent: false),
        Post(userHandle: "@debugQueen", body: "Found a bug in production. It's not a bug, it's an undocumented feature! ✨", isGameEvent: false),
        Post(userHandle: "@designerDude", body: "Just spent 3 hours picking between two slightly different shades of blue 🎨", isGameEvent: false)
    ]
    
    static let gameEventPosts = [
        // Opportunities
        Post(userHandle: "@recruiterPro", body: "Looking for a talented developer for a contract role! DM for details 💼 #hiring", isGameEvent: true),
        Post(userHandle: "@startupCEO", body: "Need a freelance developer for a quick project. Paying well! 💰", isGameEvent: true),
        Post(userHandle: "@techConf", body: "Early bird tickets for DevCon 2024 are now available! 🎟️", isGameEvent: true),
        
        // Unwanted Expenses
        Post(userHandle: "@techSupport", body: "Major security vulnerability found in popular dev tools. Update required! 🔒", isGameEvent: true),
        Post(userHandle: "@cloudProvider", body: "Scheduled maintenance fee increase starting next month 📈", isGameEvent: true),
        
        // Trending Topics
        Post(userHandle: "@techTrends", body: "New programming language taking the industry by storm! Time to learn? 📚", isGameEvent: true),
        Post(userHandle: "@marketWatch", body: "Tech stocks hitting all-time highs! 📊", isGameEvent: true)
    ]
} 