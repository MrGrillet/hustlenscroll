import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
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
                    
                    Text(gameState.currentPlayer.role)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if let goal = gameState.profile?.goal {
                        Text(goal.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
                .padding()
                
                // Bio Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Bio")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text("Aspiring tech professional focused on \(gameState.currentPlayer.role.lowercased()) roles. Working towards \(gameState.profile?.goal.description ?? "professional growth").")
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
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameState())
} 