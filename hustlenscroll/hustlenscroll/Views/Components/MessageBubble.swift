import SwiftUI

struct MessageBubble: View {
    @Binding var message: Message
    @EnvironmentObject var gameState: GameState
    
    private var isUserMessage: Bool {
        message.senderName == gameState.currentPlayer.name
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            HStack(alignment: .top, spacing: 12) {
                if !isUserMessage {
                    // Profile image for other users
                    ProfileImage(senderId: message.senderId, size: 40)
                        .frame(width: 40)
                }
                
                // Message content that takes remaining space
                VStack(alignment: isUserMessage ? .trailing : .leading, spacing: 0) {
                    // Message content
                    Text(message.content)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: isUserMessage ? .trailing : .leading)
                        .padding()
                        .foregroundColor(isUserMessage ? .white : .black)
                        .background(isUserMessage ? Color.black : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    // Opportunity details if present
                    if let opportunity = message.opportunity {
                        MessageOpportunityView(opportunity: opportunity)
                            .frame(maxWidth: .infinity, alignment: isUserMessage ? .trailing : .leading)
                            .padding(.top, message.id == message.opportunityId ? 20 : 0)
                        
                        // Only show buttons if this is the original opportunity message and it's pending
                        if message.opportunityStatus == .pending && message.id == message.opportunityId {
                            // Check if there are any responses to this opportunity
                            let hasResponses = gameState.messages.contains { msg in
                                msg.opportunityId == message.id && msg.id != message.id
                            }
                            
                            // Check if opportunity has expired
                            let isExpired = opportunity.expiryDate < Date()
                            
                            if !hasResponses {
                                if isExpired {
                                    // Show expired state
                                    Text("Offer Expired")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 0)
                                        .padding(.top, 20)
                                        .onAppear {
                                            // Add expiry message if not already added
                                            if !gameState.messages.contains(where: { $0.opportunityId == message.id && $0.content.contains("too late") }) {
                                                gameState.handleOpportunityResponse(message: message, accepted: false, expired: true)
                                            }
                                        }
                                } else {
                                    switch opportunity.type {
                                    case .startup:
                                        Button {
                                            // Show business purchase view (acceptance happens after payment selection)
                                            NotificationCenter.default.post(
                                                name: NSNotification.Name("ShowBusinessPurchase"),
                                                object: nil,
                                                userInfo: ["opportunity": BusinessOpportunity(
                                                    title: opportunity.title,
                                                    description: opportunity.description,
                                                    source: .broker,
                                                    opportunityType: .startup,
                                                    monthlyRevenue: opportunity.monthlyRevenue ?? 0,
                                                    monthlyExpenses: opportunity.monthlyExpenses ?? 0,
                                                    setupCost: opportunity.requiredInvestment ?? 0,
                                                    potentialSaleMultiple: 3.0,
                                                    revenueShare: opportunity.revenueShare ?? 100,
                                                    symbol: opportunity.title,
                                                    originalOpportunityId: opportunity.id
                                                )]
                                            )
                                        } label: {
                                            Text("Review Accounts")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                        .padding(.horizontal, 0)
                                        .padding(.top, 20)
                                        
                                    case .investment:
                                        Button {
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
                                        } label: {
                                            Text("Open Trading App")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                        .padding(.horizontal, 0)
                                        .padding(.top, 4)
                                        
                                    default:
                                        EmptyView()
                                    }
                                }
                            } else if let status = message.opportunityStatus {
                                // Show status text with more prominent styling
                                Text(status == .accepted ? "Accepted ✓" : "Rejected ×")
                                    .font(.headline)
                                    .foregroundColor(status == .accepted ? .green : .red)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(status == .accepted ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                    )
                                    .padding(.top, 4)
                            }
                        }
                    }
                    
                    // Timestamp at bottom
                    Text(formatTimestamp(message.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .hidden()
                }
            }
            .frame(maxWidth: .infinity, alignment: isUserMessage ? .trailing : .leading)
            .padding(.trailing, isUserMessage ? 12 : 0)
            
            if isUserMessage {
                // Profile image for user messages
                if let profileImage = gameState.getProfileImage() {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 8)
        // Add large spacing only after broker's follow-up (which is a response message from the broker)
        .padding(.bottom, message.opportunityId != nil && message.id != message.opportunityId && !isUserMessage ? 60 : 4)
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
                        Text("Your Ownership:")
                            .font(.subheadline)
                        Text("\(Int(share))% of Revenue (paid as dividends)")
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
                
                // Add Company Reference (ID)
                HStack {
                    Text("Company Reference:")
                        .font(.subheadline)
                    Text(opportunity.id.uuidString.prefix(8))
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                }
                
                // Add Offer Expiry (Date)
                HStack {
                    Text("Offer Expires:")
                        .font(.subheadline)
                    Text(opportunity.expiryDate, style: .time)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
} 