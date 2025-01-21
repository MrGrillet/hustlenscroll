import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showingGoalSelection = false
    @State private var selectedRole: String?
    @State private var showingRoleDetail = false
    @State private var roleToShow: Role?
    
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
                        HStack(spacing: 12) {
                            // Role info and details button
                            Button {
                                if let role = Role.getRole(byTitle: career.role) {
                                    roleToShow = role
                                    showingRoleDetail = true
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(career.role)
                                            .font(.headline)
                                        Text("$\(Int(career.salary))/month")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "info.circle")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            
                            // Select button
                            Button {
                                selectedRole = career.role
                                selectCareer(role: career.role)
                            } label: {
                                Text(selectedRole == career.role ? "Selected" : "Select")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                    .padding()
                                    .background(selectedRole == career.role ? Color.green : Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    showingGoalSelection = true
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedRole != nil ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(selectedRole == nil)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingRoleDetail) {
            if let role = roleToShow {
                RoleDetailSheet(
                    role: role,
                    isSelected: selectedRole == role.title,
                    onSelect: { _ in
                        selectedRole = role.title
                        selectCareer(role: role.title)
                        showingRoleDetail = false
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showingGoalSelection) {
            GoalSelectionView()
        }
    }
    
    private func selectCareer(role: String) {
        gameState.currentPlayer = Player(
            name: "Player",
            role: role
        )
        gameState.saveState()
    }
}

struct CareerButton: View {
    let role: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(role)
                    .font(.headline)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color.gray.opacity(0.8))
            .cornerRadius(10)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameState())
} 