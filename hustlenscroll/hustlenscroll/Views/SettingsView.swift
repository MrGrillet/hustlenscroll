import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    @State private var playerName: String
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isLoadingImage = false
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
                    // Profile Image Section
                    VStack(alignment: .center, spacing: 12) {
                        if isLoadingImage {
                            ProgressView()
                                .frame(width: 100, height: 100)
                        } else if let image = selectedImage ?? gameState.getProfileImage() {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 100, height: 100)
                        }
                        
                        PhotosPicker(selection: $selectedItem,
                                   matching: .images,
                                   photoLibrary: .shared()) {
                            Text("Change Profile Photo")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
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
            .onAppear {
                // Initialize handle from current player
                if let handle = gameState.currentPlayer.handle {
                    playerHandle = handle
                }
            }
            .onChange(of: selectedItem) { _, item in
                Task {
                    isLoadingImage = true
                    if let data = try? await item?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            gameState.updateProfileImage(data)
                        }
                    }
                    isLoadingImage = false
                }
            }
        }
    }
} 