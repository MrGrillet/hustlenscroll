import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showingArchivedMessages = false
    
    var body: some View {
        NavigationView {
            List {
                if gameState.activeMessages.isEmpty {
                    Text("No messages yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(gameState.activeMessages) { message in
                        MessageRow(message: message)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingArchivedMessages.toggle()
                    } label: {
                        Image(systemName: "archivebox")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingArchivedMessages) {
                ArchivedMessagesView()
            }
        }
    }
}

struct MessageRow: View {
    let message: Message
    @EnvironmentObject var gameState: GameState
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
            gameState.markMessageAsRead(message)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Profile Image
                ProfileImage(senderId: message.senderId, size: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Sender Info
                    HStack {
                        Text(message.senderName)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(formatTimestamp(message.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(message.senderRole)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Preview
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .padding(.top, 2)
                    
                    // Status indicators
                    if let status = message.opportunityStatus {
                        HStack {
                            switch status {
                            case .accepted:
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Accepted")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            case .rejected:
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Declined")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            case .pending:
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                Text("Pending")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.vertical, 8)
            .opacity(message.isRead ? 0.8 : 1.0)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button {
                withAnimation {
                    gameState.archiveMessage(message)
                }
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showingDetail) {
            MessageDetailView(message: message)
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
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

struct ArchivedMessagesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            List {
                if gameState.archivedMessages.isEmpty {
                    Text("No archived messages")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(gameState.archivedMessages) { message in
                        MessageRow(message: message)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Archived")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct MessageDetailView: View {
    let message: Message
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    @State private var showingOpportunityDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Sender Info
                    HStack(spacing: 12) {
                        ProfileImage(senderId: message.senderId, size: 50)
                        
                        VStack(alignment: .leading) {
                            Text(message.senderName)
                                .font(.title3)
                                .bold()
                            Text(message.senderRole)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom)
                    
                    // Message Content
                    Text(message.content)
                        .font(.body)
                    
                    // Opportunity Details
                    if let opportunity = message.opportunity {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Opportunity Details")
                                .font(.headline)
                                .padding(.top)
                            
                            Text(opportunity.title)
                                .font(.title3)
                                .bold()
                            
                            Text(opportunity.description)
                                .foregroundColor(.gray)
                            
                            if let investment = opportunity.requiredInvestment {
                                Text("Required Investment: $\(Int(investment))")
                                    .font(.subheadline)
                                    .padding(.top, 4)
                            }
                            
                            if message.opportunityStatus == nil {
                                HStack {
                                    Button {
                                        gameState.handleOpportunityResponse(message: message, accepted: true)
                                        dismiss()
                                    } label: {
                                        Text("Accept")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    
                                    Button {
                                        gameState.handleOpportunityResponse(message: message, accepted: false)
                                        dismiss()
                                    } label: {
                                        Text("Decline")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.red.opacity(0.1))
                                            .foregroundColor(.red)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.top)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
} 