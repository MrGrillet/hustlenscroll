import SwiftUI

@main
struct HustlenscrollApp: App {
    @StateObject private var gameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            if gameState.currentPlayer.name.isEmpty {
                OnboardingView()
                    .environmentObject(gameState)
            } else {
                TabView {
                    FeedView()
                        .tabItem {
                            Label("Feed", systemImage: "newspaper")
                        }
                    
                    DMListView()
                        .tabItem {
                            Label("Messages", systemImage: "message")
                        }
                        .badge(gameState.unreadMessageCount)
                    
                    BankView()
                        .tabItem {
                            Label("Bank", systemImage: "dollarsign.circle")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                }
                .environmentObject(gameState)
            }
        }
    }
} 