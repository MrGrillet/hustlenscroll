import SwiftUI

struct RoleSelectionButton: View {
    let role: Role
    let isSelected: Bool
    let showDetail: () -> Void
    
    var body: some View {
        Button(action: showDetail) {
            HStack {
                VStack(alignment: .leading) {
                    Text(role.title)
                        .font(.headline)
                    Text("$\(Int(role.monthlySalary))/month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
} 