import SwiftUI

struct MessageDetailView: View {
    let message: Message
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Sender Info
                    HStack {
                        VStack(alignment: .leading) {
                            Text(message.senderName)
                                .font(.title2)
                                .bold()
                            Text(message.senderRole)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(formatDate(message.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom)
                    
                    // Message Content
                    Text(message.content)
                        .font(.body)
                    
                    // Opportunity Details (if exists)
                    if let opportunity = message.opportunity {
                        OpportunityDetailView(opportunity: opportunity)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if !message.isRead {
                    gameState.markMessageAsRead(message)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

struct OpportunityDetailView: View {
    let opportunity: Opportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            Text("Opportunity Details")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(opportunity.title)
                    .font(.title3)
                    .bold()
                
                Text(opportunity.description)
                    .foregroundColor(.gray)
                
                if let revenue = opportunity.monthlyRevenue {
                    HStack {
                        Text("Monthly Revenue:")
                        Text("$\(Int(revenue).formatted())")
                            .bold()
                    }
                    .foregroundColor(.green)
                }
                
                if let expenses = opportunity.monthlyExpenses {
                    HStack {
                        Text("Monthly Expenses:")
                        Text("$\(Int(expenses).formatted())")
                            .bold()
                    }
                    .foregroundColor(.red)
                }
                
                if let revenue = opportunity.monthlyRevenue,
                   let expenses = opportunity.monthlyExpenses {
                    HStack {
                        Text("MRR (Monthly Cashflow):")
                        Text("$\(Int(revenue - expenses).formatted())")
                            .bold()
                    }
                    .foregroundColor(.blue)
                }
                
                if let investment = opportunity.requiredInvestment {
                    HStack {
                        Text("Setup Costs (paid today):")
                        Text("$\(Int(investment).formatted())")
                            .bold()
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
} 