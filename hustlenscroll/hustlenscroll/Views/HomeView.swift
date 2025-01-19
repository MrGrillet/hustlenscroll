import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameState: GameState
    @State private var navigateToGame = false
    @State private var showingGoalSelection = false
    
    // Career options with their default salaries
    private let careers: [(role: String, salary: Double)] = [
        ("Junior Developer", 3000),
        ("Senior Developer", 5000),
        ("Product Manager", 4500),
        ("Designer", 4000)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Hustle & Scroll")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 50)
                
                Text("Choose Your Persona")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer().frame(height: 30)
                
                VStack(spacing: 16) {
                    ForEach(careers, id: \.role) { career in
                        CareerButton(
                            role: career.role,
                            action: {
                                selectCareer(role: career.role, salary: career.salary)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToGame) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $showingGoalSelection) {
                GoalSelectionView()
                    .onDisappear {
                        if gameState.playerGoal != nil {
                            navigateToGame = true
                        }
                    }
            }
        }
    }
    
    private func selectCareer(role: String, salary: Double) {
        let newPlayer = Player(
            name: "New Player",
            role: role
        )
        
        gameState.startNewGame(with: newPlayer)
        showingGoalSelection = true
    }
}

struct CareerButton: View {
    let role: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(role)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameState())
} 