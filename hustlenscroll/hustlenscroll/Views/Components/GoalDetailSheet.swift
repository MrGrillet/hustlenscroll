import SwiftUI

struct GoalDetailSheet: View {
    let goal: Goal
    let isSelected: Bool
    let onSelection: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Goal Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(goal.title)
                            .font(.title)
                            .bold()
                        Text("Target: $\(Int(goal.price).formattedWithSeparator)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    // Goal Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About this Goal")
                            .font(.headline)
                        Text(goal.longDescription)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Requirements
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requirements")
                            .font(.headline)
                        Text(goal.requirements)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Progress Indicator
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress")
                            .font(.headline)
                        ProgressView(value: 0.0)
                            .tint(.blue)
                        Text("$0 of $\(Int(goal.price).formattedWithSeparator)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // Select Button
                    Button {
                        onSelection(true)
                        dismiss()
                    } label: {
                        Text("Select This Goal")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                }
                .padding()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
} 