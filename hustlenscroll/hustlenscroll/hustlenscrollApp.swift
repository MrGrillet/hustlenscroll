import SwiftUI

@main
struct HustleAndScrollApp: App {
    @StateObject private var gameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            HomeView()  // Start with HomeView instead of ContentView
                .environmentObject(gameState)
        }
    }
} 