import Foundation

struct DummyUser {
    let name: String
    let role: String
    let handle: String
}

struct SampleContent {
    static let users: [DummyUser] = [
        // Tech People
        DummyUser(name: "Sarah Chen", role: "Tech Lead", handle: "@sarahcodes"),
        DummyUser(name: "Alex Rivera", role: "Startup Founder", handle: "@alexbuilds"),
        DummyUser(name: "Maya Patel", role: "Product Manager", handle: "@mayaships"),
        DummyUser(name: "James Wilson", role: "Senior Developer", handle: "@jwilsondev"),
        DummyUser(name: "Ava Johnson", role: "UX Designer", handle: "@avadesigns"),
        DummyUser(name: "Marcus Brown", role: "DevOps Engineer", handle: "@marcusops"),
        DummyUser(name: "Emma Liu", role: "Data Scientist", handle: "@emmalytics"),
        DummyUser(name: "Carlos Rodriguez", role: "Mobile Developer", handle: "@carlosapps"),
        
        // Industry Figures
        DummyUser(name: "TechCrunch", role: "Tech News", handle: "@techcrunch"),
        DummyUser(name: "VentureDaily", role: "VC News", handle: "@venturedaily"),
        DummyUser(name: "StartupInsider", role: "Startup News", handle: "@startupinsider"),
        DummyUser(name: "CryptoWatch", role: "Crypto News", handle: "@cryptowatch")
    ]
    
    static let postTemplates = [
        // Tech Updates
        "{Just|Finally|Successfully} {shipped|deployed|launched} my {new|latest} {project|app|startup}! {🚀|✨|💫}",
        "{Can't believe|Wow|Amazing} how much you can {learn|grow|achieve} in {tech|startups|coding} {these days|nowadays|lately} {💡|🎯|⚡️}",
        "Working on {something big|a new venture|an exciting project}... {stay tuned|more soon|details coming} {👀|💪|🔥}",
        
        // Tech Opinions
        "{Love|Enjoying|Appreciating} the {journey|process|grind} of {building|creating|developing} {something new|from scratch|with passion} {❤️|🙏|✨}",
        "Hot take: {React|TypeScript|SwiftUI} is {the future|game-changing|revolutionary} for {web dev|app development|frontend} {🔥|💭|💡}",
        "{Anyone else|Who else} {thinking|feeling} that {AI|blockchain|web3} is {overhyped|underrated|misunderstood}? {🤔|💭|❓}",
        
        // Daily Dev Life
        "Day {23|45|78} of {learning|building|coding}: {making progress|getting there|feeling good} {💪|✨|🎯}",
        "{Debug|Standup|Planning} meeting {went well|finished early|was productive} today! {Time to code|Back to building|Let's ship this} {💻|⚡️|🚀}",
        "That feeling when {your tests pass|your deploy succeeds|your code works} on the first try {😌|🙌|✨}",
        
        // Industry Commentary
        "Interesting {article|thread|post} about {AI ethics|startup funding|tech trends} - thoughts? {🤔|💭|❓}",
        "The {tech|startup|crypto} market is {looking interesting|showing promise|heating up} {lately|these days|right now} {📈|🎯|👀}",
        "{Big news|Major update|Game changer} in the {tech|startup|crypto} world today! {Check it out|What do you think|Thoughts?} {🔥|📢|💡}",
        
        // Career/Learning
        "{Started|Beginning|Diving into} a new {course|project|challenge} in {AI|blockchain|cloud} development {today|this week|this month} {📚|💡|🎯}",
        "Just {earned|got|received} my {AWS|Google Cloud|Azure} certification! {Next stop|Now onto|Time for} {more learning|new projects|bigger challenges} {🎉|🏆|💪}",
        "{Mentor|Lead|Manager} gave great {feedback|advice|insights} today about {scaling|architecture|best practices} {📝|💡|🎯}",
        
        // Startup Life
        "{Pitched|Presented|Demoed} to {investors|clients|partners} today - {went well|looking promising|feeling optimistic}! {🎤|💼|🚀}",
        "Month {3|6|12} of my {startup|indie project|side hustle}: {revenue growing|users increasing|metrics improving} {📈|💪|🎯}",
        "{Celebrating|Happy about|Excited for} our {first|latest|biggest} {customer win|funding round|partnership} {today|this week|this month}! {🎉|🥂|🚀}"
    ]
    
    static let techKeywords = [
        "AI", "blockchain", "cloud", "DevOps", "React", "Swift", "Python",
        "machine learning", "web3", "crypto", "NFTs", "startups"
    ]
    
    static let rejectionResponses = [
        "No problem, I understand! Thanks for considering the opportunity. Let me know if anything changes in the future.",
        "Thanks for letting me know. I appreciate your quick response. Feel free to reach out if you change your mind!",
        "I understand completely. Timing isn't always right. Keep in touch and good luck with your journey!",
        "Thanks for the honest feedback. If another opportunity comes up that might be a better fit, I'll let you know.",
        "Appreciate you taking the time to consider it. Best of luck with your current endeavors!"
    ]
    
    static func getRandomRejectionResponse() -> String {
        rejectionResponses.randomElement() ?? rejectionResponses[0]
    }
    
    static func generateFillerPosts(count: Int) -> [Post] {
        var posts: [Post] = []
        
        for _ in 0..<count {
            let user = users.randomElement()!
            let template = postTemplates.randomElement()!
            let content = SpintaxGenerator.spin(template)
            
            posts.append(Post(
                id: UUID(),
                author: user.name,
                role: user.role,
                content: content,
                timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400)), // Random time in last 24h
                isSponsored: false,
                linkedOpportunity: nil
            ))
        }
        
        return posts.sorted { $0.timestamp > $1.timestamp }
    }
    
    static func generateTrendingPost() -> Post {
        let keyword = techKeywords.randomElement()!
        let template = "{Breaking|Hot|Trending}: \(keyword) {market|industry|sector} is {booming|growing|exploding} {🔥|📈|🚀}"
        
        let user = DummyUser(
            name: "TechTrends",
            role: "Market Analysis",
            handle: "@techtrends"
        )
        
        return Post(
            id: UUID(),
            author: user.name,
            role: user.role,
            content: SpintaxGenerator.spin(template),
            timestamp: Date(),
            isSponsored: true,
            linkedOpportunity: nil
        )
    }
} 