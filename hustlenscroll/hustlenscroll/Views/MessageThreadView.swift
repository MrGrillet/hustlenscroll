import SwiftUI
import Combine

struct ThreadMessageRow: View {
    @EnvironmentObject var gameState: GameState
    let message: Message
    let onBusinessOpportunity: (BusinessOpportunity) -> Void
    
    var businessOpportunity: BusinessOpportunity? {
        if let opportunity = message.opportunity,
           opportunity.type == .startup {
            return BusinessOpportunity(
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
            )
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 10) {
            MessageBubble(message: Binding(
                get: { message },
                set: { newMessage in
                    if let index = gameState.messages.firstIndex(where: { $0.id == newMessage.id }) {
                        gameState.messages[index] = newMessage
                    }
                }
            ))
            .id(message.id)
            .onAppear {
                if !message.isRead {
                    gameState.markMessageAsRead(message)
                }
            }
        }
    }
}

class MessageThreadViewModel: ObservableObject {
    @Published var showingInvestmentPurchase = false
    @Published var showingBusinessPurchase = false
    @Published var selectedAsset: Asset?
    @Published var selectedOpportunity: BusinessOpportunity?
    
    init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowInvestmentPurchase"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let asset = notification.userInfo?["asset"] as? Asset {
                self?.selectedAsset = asset
                self?.showingInvestmentPurchase = true
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowBusinessPurchase"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let opportunity = notification.userInfo?["opportunity"] as? BusinessOpportunity {
                self?.selectedOpportunity = opportunity
                self?.showingBusinessPurchase = true
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct MessageThreadView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var viewModel = MessageThreadViewModel()
    let thread: MessageThread
    @State private var scrollProxy: ScrollViewProxy?
    @State private var lastMessageId: UUID?
    
    private func findMessage(for id: UUID) -> Message? {
        gameState.messages.first { $0.id == id }
    }
    
    var messages: [Message] {
        var result: [Message] = []
        for id in thread.messageIds {
            if let message = findMessage(for: id) {
                result.append(message)
            }
        }
        return result
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 16) {
                    Spacer(minLength: 20)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(messages, id: \.id) { message in
                            ThreadMessageRow(message: message) { opportunity in
                                viewModel.selectedOpportunity = opportunity
                                viewModel.showingBusinessPurchase = true
                            }
                        }
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 20)
                }
                .onAppear {
                    scrollProxy = proxy
                    lastMessageId = messages.last?.id
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastId = lastMessageId {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                .onChange(of: messages.count) { _, _ in
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
        .sheet(isPresented: $viewModel.showingInvestmentPurchase) {
            if let asset = viewModel.selectedAsset {
                InvestmentPurchaseView(asset: asset)
            } else {
                Text("Unable to load investment view")
            }
        }
        .sheet(isPresented: $viewModel.showingBusinessPurchase) {
            if let opportunity = viewModel.selectedOpportunity {
                BusinessPurchaseView(opportunity: opportunity)
            } else {
                Text("Unable to load business view")
            }
        }
    }
} 