import SwiftUI

struct BankView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Financial Dashboard")
                .font(.largeTitle)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(title: "Name", value: gameState.currentPlayer.name)
                InfoRow(title: "Role", value: gameState.currentPlayer.role)
                InfoRow(title: "Bank Balance", value: String(format: "$%.2f", gameState.currentPlayer.bankBalance))
                InfoRow(title: "Monthly Salary", value: String(format: "$%.2f", gameState.currentPlayer.monthlySalary))
                InfoRow(title: "Monthly Expenses", value: String(format: "$%.2f", gameState.currentPlayer.monthlyExpenses))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            Button(action: {
                gameState.advanceTurn()
            }) {
                Text("Advance Turn")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
} 