import SwiftUI

struct MessageBubble: View {
    @Binding var message: Message
    @EnvironmentObject var gameState: GameState
    @State private var showingInvestmentPurchase = false
    @State private var selectedAsset: Asset?
    @State private var isProcessing = false
    
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
                    
                    // Accept/Reject buttons
                    if message.opportunityStatus == .pending {
                        HStack(spacing: 16) {
                            Button(action: {
                                isProcessing = true
                                gameState.handleOpportunityResponse(message: message, accepted: true)
                                isProcessing = false
                            }) {
                                HStack {
                                    if isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Accept")
                                    }
                                }
                                .frame(minWidth: 100)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(isProcessing ? Color.gray : Color.green)
                                .cornerRadius(8)
                            }
                            .disabled(isProcessing)
                            
                            Button(action: {
                                isProcessing = true
                                gameState.handleOpportunityResponse(message: message, accepted: false)
                                isProcessing = false
                            }) {
                                HStack {
                                    if isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Reject")
                                    }
                                }
                                .frame(minWidth: 100)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(isProcessing ? Color.gray : Color.red)
                                .cornerRadius(8)
                            }
                            .disabled(isProcessing)
                        }
                        .padding(.top, 12)
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowInvestmentPurchase"))) { notification in
            if let asset = notification.userInfo?["asset"] as? Asset {
                selectedAsset = asset
                showingInvestmentPurchase = true
            }
        }
        .sheet(isPresented: $showingInvestmentPurchase) {
            if let asset = selectedAsset {
                InvestmentPurchaseView(asset: asset)
            }
        }
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