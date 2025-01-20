import SwiftUI

struct DMListView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedThread: MessageThread?
    
    // Group messages by sender
    var messageThreads: [MessageThread] {
        Dictionary(grouping: gameState.activeMessages) { $0.senderId }
            .map { senderId, messages in
                let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
                return MessageThread(
                    senderId: senderId,
                    senderName: messages[0].senderName,
                    senderRole: messages[0].senderRole,
                    messageIds: sortedMessages.map { $0.id },
                    hasUnread: messages.contains { !$0.isRead }
                )
            }
            .sorted { thread1, thread2 in
                let lastMessage1 = gameState.messages.first(where: { $0.id == thread1.messageIds.last })
                let lastMessage2 = gameState.messages.first(where: { $0.id == thread2.messageIds.last })
                return (lastMessage1?.timestamp ?? Date()) > (lastMessage2?.timestamp ?? Date())
            }
    }
    
    var body: some View {
        NavigationStack {
            List(messageThreads) { thread in
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
                        Label("Archive", systemImage: "archivebox")
                    }
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
    
    var firstMessage: Message? {
        gameState.messages.first(where: { $0.id == thread.messageIds.first })
    }
    
    var hasUnreadMessages: Bool {
        thread.messageIds.contains { id in
            gameState.messages.first(where: { $0.id == id })?.isRead == false
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileImage(senderId: thread.senderId, size: 50)
            
            VStack(alignment: .leading) {
                Text(thread.senderName)
                    .font(.headline)
                Text(thread.senderRole)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if let message = firstMessage {
                    Text(message.content)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if hasUnreadMessages {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MessageThreadView: View {
    @EnvironmentObject var gameState: GameState
    let thread: MessageThread
    @State private var scrollProxy: ScrollViewProxy?
    @State private var lastMessageId: UUID?
    
    var messages: [Message] {
        thread.messageIds.compactMap { id in
            gameState.messages.first { $0.id == id }
        }
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
                .onAppear {
                    scrollProxy = proxy
                    lastMessageId = messages.last?.id
                    
                    // Mark all messages as read immediately when view appears
                    DispatchQueue.main.async {
                        for message in messages {
                            if !message.isRead {
                                gameState.markMessageAsRead(message)
                            }
                        }
                    }
                    
                    // Scroll to bottom with animation
                    if let lastId = lastMessageId {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: messages.count) { oldCount, newCount in
                    // If new messages arrive, scroll to the new last message
                    // and mark them as read
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                        // Mark any new unread messages as read
                        for message in messages {
                            if !message.isRead {
                                gameState.markMessageAsRead(message)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(thread.senderName)
    }
}

struct MessageThread: Identifiable, Hashable {
    let id: String
    let senderId: String
    let senderName: String
    let senderRole: String
    let messageIds: [UUID]
    
    // Make hasUnread a computed property that checks GameState
    var hasUnread: Bool {
        // This will be set by the view that has access to GameState
        false
    }
    
    // Implement hash(into:) for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement == for Hashable conformance
    static func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
        lhs.id == rhs.id
    }
    
    init(senderId: String, senderName: String, senderRole: String, messageIds: [UUID], hasUnread: Bool) {
        self.id = senderId
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.messageIds = messageIds
    }
} 