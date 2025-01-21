import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentStep = 1
    @State private var name = ""
    @State private var handle = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isLoadingImage = false
    @State private var selectedRole: Role?
    @State private var selectedGoal: Goal?
    @State private var showingDMList = false
    @State private var roleToShowDetails: Role?
    @State private var goalToShowDetails: Goal?
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress indicator
                ProgressView(value: Double(currentStep), total: 6)
                    .padding()
                
                // Content based on current step
                switch currentStep {
                case 1:
                    welcomeView
                case 2:
                    nameAndHandleView
                case 3:
                    profileImageView
                case 4:
                    roleSelectionView
                case 5:
                    goalView
                case 6:
                    completionView
                default:
                    Text("Invalid step")
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentStep > 1 {
                        Button("Back") {
                            currentStep -= 1
                        }
                    }
                    
                    Spacer()
                    
                    if currentStep < 6 {
                        Button("Next") {
                            currentStep += 1
                        }
                        .disabled(!canProceed)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingDMList) {
            TabView {
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "newspaper")
                    }
                
                DMListView()
                    .tabItem {
                        Label("Messages", systemImage: "message")
                    }
                    .badge(gameState.unreadMessageCount)
                
                BankView()
                    .tabItem {
                        Label("Bank", systemImage: "dollarsign.circle")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .environmentObject(gameState)
        }
    }
    
    // MARK: - View Components
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Welcome to HustleNScroll")
                .font(.title)
                .bold()
            
            Text("Your journey to financial independence starts here")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text("Let's set up your profile in a few simple steps")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var nameAndHandleView: some View {
        VStack(spacing: 20) {
            Text("What's your name?")
                .font(.title2)
                .bold()
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Text("Choose a handle")
                .font(.title2)
                .bold()
            
            TextField("@handle", text: $handle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
        }
        .padding()
    }
    
    private var profileImageView: some View {
        VStack(spacing: 20) {
            Text("Add a profile photo")
                .font(.title2)
                .bold()
            
            if isLoadingImage {
                ProgressView()
                    .frame(width: 100, height: 100)
            } else if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 100, height: 100)
            }
            
            PhotosPicker(selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                Text("Choose Photo")
                    .foregroundColor(.blue)
            }
            .onChange(of: selectedItem) { _, item in
                Task {
                    isLoadingImage = true
                    if let data = try? await item?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            if let imageData = uiImage.jpegData(compressionQuality: 0.7) {
                                gameState.updateProfileImage(imageData)
                            }
                        }
                    }
                    isLoadingImage = false
                }
            }
        }
        .padding()
    }
    
    private var roleSelectionView: some View {
        VStack {
            Text("Choose Your Role")
                .font(.title)
                .padding()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Role.allRoles) { role in
                        HStack {
                            // Role info
                            VStack(alignment: .leading) {
                                Text(role.title)
                                    .font(.headline)
                                Text("$\(Int(role.monthlySalary))/month")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Details button
                            Button {
                                roleToShowDetails = role  // Show details for this specific role
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                            }
                            
                            // Select button
                            Button {
                                selectedRole = role
                                gameState.setRole(role.title)
                                currentStep += 1
                            } label: {
                                Text(selectedRole?.title == role.title ? "Selected" : "Select")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedRole?.title == role.title ? Color.green : Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(selectedRole?.title == role.title ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .sheet(item: $roleToShowDetails) { role in
            RoleDetailSheet(
                role: role,
                isSelected: selectedRole?.title == role.title,
                onSelect: { _ in
                    selectedRole = role
                    gameState.setRole(role.title)
                    roleToShowDetails = nil  // Dismiss sheet
                    currentStep += 1
                }
            )
        }
    }
    
    private var goalView: some View {
        VStack(spacing: 20) {
            Text("What's your goal?")
                .font(.title2)
                .bold()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Goal.allCases) { goal in
                        HStack {
                            // Goal info
                            VStack(alignment: .leading, spacing: 8) {
                                Text(goal.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Target: $\(Int(goal.price).formattedWithSeparator)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            // Details button
                            Button {
                                goalToShowDetails = goal  // Show details for this specific goal
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                            }
                            
                            // Select button
                            Button {
                                selectedGoal = goal
                                gameState.setPlayerGoal(goal)
                                currentStep += 1
                            } label: {
                                Text(selectedGoal == goal ? "Selected" : "Select")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedGoal == goal ? Color.green : Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(selectedGoal == goal ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .sheet(item: $goalToShowDetails) { goal in
            GoalDetailSheet(
                goal: goal,
                isSelected: selectedGoal == goal,
                onSelection: { _ in
                    selectedGoal = goal
                    gameState.setPlayerGoal(goal)
                    goalToShowDetails = nil  // Dismiss sheet
                    currentStep += 1
                }
            )
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("You're All Set!")
                .font(.title)
                .bold()
            
            VStack(spacing: 20) {
                Text("Your Profile")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(title: "Name", value: name)
                    if let role = selectedRole {
                        InfoRow(title: "Role", value: role.title)
                        InfoRow(title: "Monthly Income", value: "$\(Int(role.monthlySalary))")
                    }
                    if let goal = selectedGoal {
                        InfoRow(title: "Goal", value: goal.title)
                        InfoRow(title: "Target", value: "$\(Int(goal.price).formattedWithSeparator)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            Text("Ready to start your journey to financial independence?")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top)

            Button(action: {
                completeOnboarding()
            }) {
                Text("Get Started")
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
    
    // MARK: - Helper Methods
    
    private var canProceed: Bool {
        switch currentStep {
        case 1:
            return true  // Welcome screen can always proceed
        case 2:
            return !name.isEmpty && !handle.isEmpty  // Name & handle must be filled
        case 3:
            return true // Can proceed without image
        case 4:
            return selectedRole != nil  // Must select a role
        case 5:
            return selectedGoal != nil  // Must select a goal
        case 6:
            return true  // Can always proceed from completion view
        default:
            return true
        }
    }
    
    private func completeOnboarding() {
        print("DEBUG: Starting onboarding completion...")
        print("DEBUG: Current step: \(currentStep)")
        print("DEBUG: Name: \(name)")
        print("DEBUG: Handle: \(handle)")
        print("DEBUG: Selected role: \(selectedRole?.title ?? "none")")
        print("DEBUG: Selected goal: \(selectedGoal?.title ?? "none")")
        
        guard let role = selectedRole else {
            print("DEBUG: ERROR - No role selected")
            return
        }
        
        print("DEBUG: Creating player with name: \(name), role: \(role.title), handle: \(handle)")
        // Create player with actual name and handle
        let player = Player(name: name, role: role.title, handle: handle)
        
        // Update all state in sequence
        DispatchQueue.main.async {
            print("DEBUG: Updating game state...")
            // Start new game with player
            self.gameState.startNewGame(with: player)
            
            // Set goal
            if let goal = self.selectedGoal {
                print("DEBUG: Setting player goal: \(goal.title)")
                self.gameState.setPlayerGoal(goal)
            } else {
                print("DEBUG: ERROR - No goal selected")
            }
            
            // Update profile with all information
            if let goal = self.selectedGoal {
                print("DEBUG: Updating profile...")
                self.gameState.updateProfile(name: self.name, role: role.title, goal: goal)
            }
            
            // Force state save and update
            print("DEBUG: Saving game state...")
            self.gameState.saveState()
            
            // Show the DMList view
            print("DEBUG: Setting showingDMList to true")
            self.showingDMList = true
            print("DEBUG: showingDMList is now: \(self.showingDMList)")
            
            // Check if onboarding is still needed
            print("DEBUG: Checking if onboarding is still needed...")
            print("DEBUG: Current player role: \(self.gameState.currentPlayer.role)")
            print("DEBUG: Current player goal: \(String(describing: self.gameState.playerGoal))")
        }
    }
} 