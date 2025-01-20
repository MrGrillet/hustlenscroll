import SwiftUI

struct DMListView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedThread: MessageThread?
    @State private var showArchived = false
    
    // Group messages by sender
    var messageThreads: [MessageThread] {
        let filteredMessages = showArchived ? gameState.messages : gameState.activeMessages
        return Dictionary(grouping: filteredMessages) { $0.senderId }
            .map { senderId, messages in
                let sortedMessages = messages.sorted { $0.timestamp > $1.timestamp }
                return MessageThread(
                    senderId: senderId,
                    senderName: messages[0].senderName,
                    senderRole: messages[0].senderRole,
                    messageIds: sortedMessages.map { $0.id },
                    hasUnread: messages.contains { !$0.isRead },
                    lastMessageTimestamp: sortedMessages.first?.timestamp ?? Date.distantPast,
                    isArchived: messages[0].isArchived
                )
            }
            .sorted { $0.lastMessageTimestamp > $1.lastMessageTimestamp }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(messageThreads) { thread in
                    NavigationLink(value: thread) {
                        MessageThreadRow(gameState: gameState, thread: thread)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            // Archive all messages in the thread
                            for messageId in thread.messageIds {
                                if let message = gameState.messages.first(where: { $0.id == messageId }) {
                                    gameState.archiveMessage(message)
                                }
                            }
                        } label: {
                            Label(thread.isArchived ? "Unarchive" : "Archive", 
                                  systemImage: thread.isArchived ? "tray.and.arrow.up" : "archivebox")
                        }
                    }
                }
                
                Section {
                    Toggle(isOn: $showArchived) {
                        HStack {
                            Image(systemName: "archivebox")
                                .foregroundColor(.gray)
                            Text("Show Archived Messages")
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.blue)
                }
            }
            .navigationTitle("Messages")
            .navigationDestination(for: MessageThread.self) { thread in
                MessageThreadView(thread: thread)
            }
        }
    }
}

struct MessageThreadRow: View {
    @ObservedObject var gameState: GameState
    let thread: MessageThread
    
    var lastMessage: Message? {
        gameState.messages.first(where: { $0.id == thread.messageIds.first })
    }
    
    var hasUnreadMessages: Bool {
        thread.messageIds.contains { id in
            gameState.messages.first(where: { $0.id == id })?.isRead == false
        }
    }
    
    var formattedTimestamp: String {
        guard let timestamp = lastMessage?.timestamp else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileImage(senderId: thread.senderId, size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.senderName)
                        .font(.headline)
                    Spacer()
                    Text(formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text(thread.senderRole)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if let message = lastMessage {
                    Text(message.content)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                }
            }
            
            if hasUnreadMessages {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 4)
        .opacity(thread.isArchived ? 0.6 : 1.0)
    }
}

struct MessageThread: Identifiable, Hashable {
    let id: String
    let senderId: String
    let senderName: String
    let senderRole: String
    let messageIds: [UUID]
    let hasUnread: Bool
    let lastMessageTimestamp: Date
    let isArchived: Bool
    
    // Implement hash(into:) for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement == for Hashable conformance
    static func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
        lhs.id == rhs.id
    }
    
    init(senderId: String, senderName: String, senderRole: String, messageIds: [UUID], hasUnread: Bool, lastMessageTimestamp: Date = Date(), isArchived: Bool = false) {
        self.id = senderId
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.messageIds = messageIds
        self.hasUnread = hasUnread
        self.lastMessageTimestamp = lastMessageTimestamp
        self.isArchived = isArchived
    }
} 