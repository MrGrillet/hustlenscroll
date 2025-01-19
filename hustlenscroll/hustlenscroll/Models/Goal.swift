import Foundation

struct Goal: Identifiable {
    let id = UUID()
    let title: String
    let shortDescription: String
    let longDescription: String
    let price: Double
    
    static let allGoals = [
        Goal(
            title: "Tech Startup Exit",
            shortDescription: "Build and sell your own tech company",
            longDescription: "Create a successful tech startup from the ground up, scale it to significant market value, and achieve a profitable exit through acquisition or IPO. This path requires building a innovative product, assembling a strong team, and navigating the challenges of startup growth.",
            price: 1_000_000
        ),
        Goal(
            title: "Real Estate Empire",
            shortDescription: "Build a portfolio of premium properties",
            longDescription: "Develop a diverse real estate portfolio including residential and commercial properties. Generate passive income through property management and appreciation, while building long-term wealth through strategic acquisitions and development.",
            price: 2_000_000
        ),
        Goal(
            title: "Early Retirement",
            shortDescription: "Achieve financial independence",
            longDescription: "Accumulate enough wealth to retire early with a comfortable lifestyle. This requires building a diverse investment portfolio, maximizing savings, and creating multiple streams of passive income to support your desired lifestyle without active work.",
            price: 3_000_000
        ),
        Goal(
            title: "Angel Investor",
            shortDescription: "Invest in promising startups",
            longDescription: "Become an influential angel investor in the tech ecosystem. Use your capital to fund promising startups while mentoring the next generation of entrepreneurs. Build a portfolio of investments that could yield significant returns while shaping the future of technology.",
            price: 5_000_000
        )
    ]
} 