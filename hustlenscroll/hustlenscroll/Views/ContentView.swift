import SwiftUI

struct ContentView: View {
    @StateObject var gameState = GameState()
    @State private var needsOnboarding = true
    
    var body: some View {
        Group {
            if needsOnboarding {
                HomeView()
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