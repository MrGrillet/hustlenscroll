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
                VStack(spacing: 16) {
                    // Add spacer at the top for better scrolling
                    Spacer(minLength: 20)
                    
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
                    
                    // Add spacer at the bottom for better scrolling
                    Spacer(minLength: 60)
                }
                .padding(.horizontal)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 20)
                }
                .onAppear {
                    scrollProxy = proxy
                    lastMessageId = messages.last?.id
                    
                    // Scroll to bottom with animation after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastId = lastMessageId {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
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
        .navigationBarTitleDisplayMode(.inline)
    }
} 