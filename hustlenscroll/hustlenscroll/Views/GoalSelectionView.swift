import SwiftUI

struct GoalSelectionView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) var dismiss
    @State private var selectedGoal: Goal?
    @State private var showingGoalDetail = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Goal")
                .font(.title)
                .bold()
            
            Text("What do you want to achieve?")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                    ForEach(Goal.allCases) { goal in
                        GoalCard(goal: goal)
                            .onTapGesture {
                                selectedGoal = goal
                                showingGoalDetail = true
                            }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingGoalDetail) {
            if let goal = selectedGoal {
                GoalDetailView(goal: goal, parentDismiss: dismiss)
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

struct GoalDetailView: View {
    let goal: Goal
    let parentDismiss: DismissAction
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(goal.title)
                        .font(.title)
                        .bold()
                    
                    Text("Target Amount")
                        .font(.headline)
                    Text("$\(Int(goal.price).formattedWithSeparator)")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Description")
                        .font(.headline)
                    Text(goal.longDescription)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Select") {
                        // Set the goal first
                        gameState.setPlayerGoal(goal)
                        
                        // Give the state a moment to update
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // Then dismiss both sheets
                            dismiss()
                            parentDismiss()
                        }
                    }
                    .bold()
                }
            }
        }
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