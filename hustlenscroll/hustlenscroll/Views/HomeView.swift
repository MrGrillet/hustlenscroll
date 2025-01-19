import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameState: GameState
    @State private var navigateToGame = false
    
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
        }
    }
    
    private func selectCareer(role: String, salary: Double) {
        let newPlayer = Player(
            name: "New Player",
            role: role,
            bankBalance: 1000,
            monthlySalary: salary,
            monthlyExpenses: 2000
        )
        
        gameState.startNewGame(with: newPlayer)
        navigateToGame = true
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