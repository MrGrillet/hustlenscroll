import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) var dismiss
    @State private var playerName: String
    @State private var playerHandle: String
    @State private var showingResetConfirmation = false
    
    init(playerName: String) {
        _playerName = State(initialValue: playerName)
        _playerHandle = State(initialValue: "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Name", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Handle (e.g. @username)", text: $playerHandle)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Reset Game")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    gameState.currentPlayer.name = playerName
                    gameState.currentPlayer.handle = playerHandle.isEmpty ? nil : playerHandle
                    gameState.saveState()
                    dismiss()
                }
            )
            .alert("Reset Game", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    gameState.resetGame()
                    dismiss()
                }
            } message: {
                Text("This will delete all progress and start a new game. This cannot be undone.")
            }
        }
        .onAppear {
            // Initialize handle from current player
            if let handle = gameState.currentPlayer.handle {
                playerHandle = handle
            }
        }
    }
} 