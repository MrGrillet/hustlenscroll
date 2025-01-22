import SwiftUI

struct MessageBubble: View {
    @Binding var message: Message
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Fixed width profile image container
            ProfileImage(senderId: message.senderId, size: 40)
                .frame(width: 40)
            
            // Message content that takes remaining space
            VStack(alignment: .leading, spacing: 8) {
                // Message content
                Text(message.content)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                // Opportunity details if present
                if let opportunity = message.opportunity {
                    MessageOpportunityView(opportunity: opportunity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Only show buttons if the message is unread and pending
                    if message.opportunityStatus == .pending {
                        switch opportunity.type {
                        case .startup:
                            Button {
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("ShowBusinessPurchase"),
                                    object: nil,
                                    userInfo: ["opportunity": BusinessOpportunity(
                                        title: opportunity.title,
                                        description: opportunity.description,
                                        source: .partner,
                                        opportunityType: .startup,
                                        monthlyRevenue: opportunity.monthlyRevenue ?? 0,
                                        monthlyExpenses: opportunity.monthlyExpenses ?? 0,
                                        setupCost: opportunity.requiredInvestment ?? 0,
                                        potentialSaleMultiple: 3.0,
                                        revenueShare: opportunity.revenueShare ?? 100,
                                        symbol: opportunity.title
                                    )]
                                )
                            } label: {
                                Text("Review Bank Accounts")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                        case .investment:
                            Button {
                                print("🔵 MessageBubble: 'Open Trading App' button pressed")
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("ShowInvestmentPurchase"),
                                    object: nil,
                                    userInfo: ["asset": Asset(
                                        id: UUID(),
                                        symbol: opportunity.title,
                                        name: opportunity.title,
                                        quantity: 0,
                                        currentPrice: opportunity.requiredInvestment ?? 0,
                                        purchasePrice: 0,
                                        type: .stock
                                    )]
                                )
                                print("🔵 MessageBubble: Posted ShowInvestmentPurchase notification")
                            } label: {
                                Text("Open Trading App")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                        default:
                            EmptyView()
                        }
                    } else if let status = message.opportunityStatus {
                        // Show status text
                        Text(status == .accepted ? "Accepted ✓" : "Rejected ×")
                            .foregroundColor(status == .accepted ? .green : .red)
                            .padding(.top, 8)
                    }
                }
                
                // Timestamp at bottom
                Text(formatTimestamp(message.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .hidden()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }
}

// Renamed to MessageOpportunityView to avoid conflicts
struct MessageOpportunityView: View {
    let opportunity: Opportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(opportunity.title)
                .font(.headline)
                .bold()
            
            // Description
            Text(opportunity.description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            // Financial Details
            Group {
                // MRR (Monthly Revenue)
                if let revenue = opportunity.monthlyRevenue {
                    HStack {
                        Text("MRR (Monthly Revenue):")
                            .font(.subheadline)
                        Text("$\(Int(revenue).formatted())")
                            .font(.subheadline)
                            .bold()
                    }
                }
                
                // Monthly Expenses
                if let expenses = opportunity.monthlyExpenses {
                    HStack {
                        Text("Monthly Expenses:")
                            .font(.subheadline)
                        Text("$\(Int(expenses).formatted())")
                            .font(.subheadline)
                            .bold()
                    }
                }
                
                // Cashflow
                if let revenue = opportunity.monthlyRevenue,
                   let expenses = opportunity.monthlyExpenses {
                    HStack {
                        Text("Monthly Cashflow:")
                            .font(.subheadline)
                        Text("$\(Int(revenue - expenses).formatted())")
                            .font(.subheadline)
                            .bold()
                    }
                }
                
                // Revenue Share
                if let share = opportunity.revenueShare {
                    HStack {
                        Text("Your Share:")
                            .font(.subheadline)
                        Text("\(Int(share))% of Revenue")
                            .font(.subheadline)
                            .bold()
                    }
                }
                
                // Investment (Setup Costs)
                if let investment = opportunity.requiredInvestment {
                    HStack {
                        Text("Setup Costs (paid today):")
                            .font(.subheadline)
                        Text("$\(Int(investment).formatted())")
                            .font(.subheadline)
                            .bold()
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
} 