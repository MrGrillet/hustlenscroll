import SwiftUI

struct DMListView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedThread: MessageThread?
    @State private var showArchived = false
    @State private var listUpdateTrigger = false
    
    // Group messages by sender
    var messageThreads: [MessageThread] {
        // When showArchived is true, show all messages. When false, only show active messages
        let filteredMessages = showArchived ? gameState.messages : gameState.activeMessages
        
        print("Total messages in gameState: \(gameState.messages.count)")
        print("Active messages: \(gameState.activeMessages.count)")
        print("Filtered messages: \(filteredMessages.count)")
        print("Unread count: \(gameState.unreadMessageCount)")
        
        // Debug print unread messages
        let unreadMessages = gameState.messages.filter { !$0.isRead }
        print("Unread messages:")
        for msg in unreadMessages {
            print("- \(msg.senderName): \(msg.content.prefix(30))...")
        }
        
        // First group messages by sender
        let threads = Dictionary(grouping: filteredMessages) { $0.senderId }
            .map { senderId, messages in
                // Get the latest message for this thread
                let latestMessage = messages.max(by: { $0.timestamp < $1.timestamp })!
                
                // Sort messages chronologically for the thread view
                let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
                
                return MessageThread(
                    gameState: gameState,
                    senderId: senderId,
                    senderName: latestMessage.senderName,
                    senderRole: latestMessage.senderRole,
                    messageIds: sortedMessages.map { $0.id },
                    lastMessageTimestamp: latestMessage.timestamp,
                    isArchived: latestMessage.isArchived
                )
            }
        
        print("Number of threads: \(threads.count)")
        
        // Sort threads by timestamp, newest first
        return threads.sorted { $0.lastMessageTimestamp > $1.lastMessageTimestamp }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(messageThreads, id: \.id) { thread in
                    NavigationLink {
                        MessageThreadView(thread: thread)
                            .onAppear {
                                print("🟢 MessageThreadView appeared for: \(thread.senderName)")
                                gameState.markThreadAsRead(senderId: thread.senderId)
                                listUpdateTrigger.toggle()
                            }
                    } label: {
                        MessageThreadRow(gameState: gameState, thread: thread)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            // Get the first message of the thread and archive it
                            if let firstMessageId = thread.messageIds.first,
                               let message = gameState.messages.first(where: { $0.id == firstMessageId }) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    gameState.archiveMessage(message)
                                    listUpdateTrigger.toggle()  // Force list update
                                }
                            }
                        } label: {
                            Label(thread.isArchived ? "Unarchive" : "Archive", 
                                  systemImage: thread.isArchived ? "tray.and.arrow.up" : "archivebox")
                        }
                        .tint(.red)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: listUpdateTrigger)
                
                Section {
                    Toggle(isOn: $showArchived.animation()) {
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
        }
        .onAppear {
            print("📋 DMListView appeared")
            gameState.objectWillChange.send()
            listUpdateTrigger.toggle()
        }
    }
}

struct MessageThreadRow: View {
    @ObservedObject var gameState: GameState
    let thread: MessageThread
    
    var lastMessage: Message? {
        // Get the most recent message instead of the first one
        gameState.messages
            .filter { thread.messageIds.contains($0.id) }
            .sorted { $0.timestamp > $1.timestamp }
            .first
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
                        .foregroundColor(.primary)
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
                        .foregroundColor(.secondary)
                }
            }
            
            if thread.isUnread {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MessageThread: Identifiable, Hashable {
    let id: String
    let senderId: String
    let senderName: String
    let senderRole: String
    let messageIds: [UUID]
    let lastMessageTimestamp: Date
    let isArchived: Bool
    private let gameState: GameState
    
    var isUnread: Bool {
        // Get all messages for this thread
        let threadMessages = gameState.messages
            .filter { messageIds.contains($0.id) }
            .sorted { $0.timestamp > $1.timestamp }
        
        // Check if the most recent message is unread
        return threadMessages.first?.isRead == false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
        lhs.id == rhs.id
    }
    
    init(gameState: GameState, senderId: String, senderName: String, senderRole: String, messageIds: [UUID], lastMessageTimestamp: Date = Date(), isArchived: Bool = false) {
        self.gameState = gameState
        self.id = senderId
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.messageIds = messageIds
        self.lastMessageTimestamp = lastMessageTimestamp
        self.isArchived = isArchived
    }
} 