import SwiftUI

struct GoalSelectionView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) var dismiss
    @State private var selectedGoal: Goal?
    @State private var showingGoalDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Your Goal")
                    .font(.title)
                    .bold()
                
                Text("What do you want to achieve?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Goal.allCases) { goal in
                            Button {
                                selectedGoal = goal
                                showingGoalDetail = true
                            } label: {
                                GoalCard(goal: goal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingGoalDetail) {
            if let goal = selectedGoal {
                GoalDetailSheet(
                    goal: goal,
                    isSelected: false,
                    onSelection: { _ in
                        gameState.setPlayerGoal(goal)
                        selectedGoal = nil
                        dismiss()
                    }
                )
            }
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(goal.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(goal.shortDescription)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Target: $\(Int(goal.price).formattedWithSeparator)")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Helper extension for number formatting
extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
} 