import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showingGoalSelection = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text(gameState.currentPlayer.name)
                            .font(.title)
                            .bold()
                        
                        if let handle = gameState.currentPlayer.handle {
                            Text(handle)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Text(gameState.currentPlayer.role)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Goal Section
                    if let goal = gameState.playerGoal {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Life Goal")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            Text(goal.title)
                                .font(.title3)
                                .bold()
                            
                            Text(goal.shortDescription)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("Target:")
                                    .foregroundColor(.gray)
                                Text("$\(Int(goal.price).formattedWithSeparator)")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    } else {
                        Button("Set Goal") {
                            showingGoalSelection = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Bio Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bio")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        Text(gameState.currentPlayer.biography)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingGoalSelection) {
            GoalSelectionView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(playerName: gameState.currentPlayer.name)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameState())
} 