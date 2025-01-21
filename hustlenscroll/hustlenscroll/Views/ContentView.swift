import SwiftUI

struct ContentView: View {
    @StateObject var gameState = GameState()
    @State private var needsOnboarding = true
    @State private var showingComposePost = false
    
    var body: some View {
        Group {
            if needsOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .environmentObject(gameState)
        .onChange(of: gameState.currentPlayer.role) { oldValue, newValue in
            checkOnboardingStatus()
        }
        .onChange(of: gameState.playerGoal) { oldValue, newValue in
            checkOnboardingStatus()
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .sheet(isPresented: $showingComposePost) {
            if let draft = gameState.draftPost {
                ComposePostView(
                    gameState: gameState,
                    initialContent: draft.content,
                    initialImages: draft.images,
                    linkedOpportunity: draft.opportunity,
                    linkedInvestment: draft.investment
                )
            } else {
                ComposePostView(gameState: gameState)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowDraftPost"))) { _ in
            showingComposePost = true
        }
    }
    
    private func checkOnboardingStatus() {
        needsOnboarding = gameState.currentPlayer.role.isEmpty || gameState.playerGoal == nil
    }
}

struct MainTabView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "newspaper")
                }
            
            DMListView()
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
                .badge(gameState.unreadMessageCount > 0 ? "\(gameState.unreadMessageCount)" : nil)
            
            BankView()
                .tabItem {
                    Label("Bank", systemImage: "banknote")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
} 