import SwiftUI

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
                // Add spacer to push content to bottom when few messages
                VStack {
                    Spacer()
                    LazyVStack(spacing: 16) {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            MessageBubble(message: Binding(
                                get: { messages[index] },
                                set: { newMessage in
                                    if let gameStateIndex = gameState.messages.firstIndex(where: { $0.id == newMessage.id }) {
                                        gameState.messages[gameStateIndex] = newMessage
                                    }
                                }
                            ))
                            .id(message.id)
                            .onAppear {
                                // Mark message as read when it becomes visible
                                if !message.isRead {
                                    gameState.markMessageAsRead(message)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 180) // Account for navigation bar and bottom bar
                .onAppear {
                    scrollProxy = proxy
                    lastMessageId = messages.last?.id
                    
                    // Scroll to bottom with animation
                    if let lastId = lastMessageId {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: messages.count) { oldCount, newCount in
                    // If new messages arrive, scroll to the new last message
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .navigationTitle(thread.senderName)
    }
} 