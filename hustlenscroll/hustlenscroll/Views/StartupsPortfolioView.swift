import SwiftUI

struct StartupsPortfolioView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Startup Investments")
                    .font(.largeTitle)
                    .padding()
                
                ForEach(gameState.activeBusinesses, id: \.title) { business in
                    StartupCard(business: business)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StartupCard: View {
    let business: BusinessOpportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(business.title)
                .font(.headline)
                .bold()
            
            // Description
            Text(business.description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            // Financial Details
            Group {
                // MRR (Monthly Revenue)
                HStack {
                    Text("MRR (Monthly Revenue):")
                        .font(.subheadline)
                    Text("$\(Int(business.monthlyRevenue).formatted())")
                        .font(.subheadline)
                        .bold()
                }
                
                // Monthly Expenses
                HStack {
                    Text("Monthly Expenses:")
                        .font(.subheadline)
                    Text("$\(Int(business.monthlyExpenses).formatted())")
                        .font(.subheadline)
                        .bold()
                }
                
                // Cashflow
                HStack {
                    Text("Monthly Cashflow:")
                        .font(.subheadline)
                    Text("$\(Int(business.monthlyCashflow).formatted())")
                        .font(.subheadline)
                        .bold()
                }
                
                // Investment
                HStack {
                    Text("Initial Investment:")
                        .font(.subheadline)
                    Text("$\(Int(business.setupCost).formatted())")
                        .font(.subheadline)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    StartupsPortfolioView()
        .environmentObject(GameState())
} 