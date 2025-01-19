import SwiftUI

@main
struct HustleAndScrollApp: App {
    @StateObject private var gameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(gameState)
        }
    }
} 