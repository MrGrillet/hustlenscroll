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
                                withAnimation {
                                    selectedGoal = goal
                                    DispatchQueue.main.async {
                                        showingGoalDetail = true
                                    }
                                }
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
        .fullScreenCover(item: $selectedGoal) { goal in
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
                            selectedGoal = nil
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Select") {
                            gameState.setPlayerGoal(goal)
                            selectedGoal = nil
                            dismiss()
                        }
                        .bold()
                    }
                }
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