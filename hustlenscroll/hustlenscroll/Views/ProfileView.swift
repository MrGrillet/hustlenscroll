import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showingGoalSelection = false
    @State private var showingSettings = false
    @State private var selectedTab = 0
    @State private var postContent: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isLoadingImages = false
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = geometry.size.width >= 768
            let maxWidth: CGFloat = isIPad ? 600 : geometry.size.width
            
            NavigationView {
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Header
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(gameState.currentPlayer.handle ?? "@\(gameState.currentPlayer.name.replacingOccurrences(of: " ", with: "").lowercased())")
                                        .font(.title)
                                        .bold()
                                    
                                    Text(gameState.currentPlayer.name)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if let profileImage = gameState.getProfileImage() {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            
                            Text(gameState.currentPlayer.role)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            Text(gameState.currentPlayer.biography)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 4)
                            
                            Divider()
                                .padding(.vertical)
                        }
                        
                        // Tabs
                        HStack(spacing: 0) {
                            TabButton(title: "Posts", isSelected: selectedTab == 0) {
                                selectedTab = 0
                            }
                            
                            TabButton(title: "Goals", isSelected: selectedTab == 1) {
                                selectedTab = 1
                            }
                            
                            TabButton(title: "Investments", isSelected: selectedTab == 2) {
                                selectedTab = 2
                            }
                        }
                        .padding(.horizontal)
                        
                        // Tab Content
                        Group {
                            if selectedTab == 0 {
                                PostsTabView(posts: gameState.userPosts)
                            } else if selectedTab == 1 {
                                GoalsTabView(goal: gameState.playerGoal)
                            } else {
                                InvestmentsTabView()
                            }
                        }
                    }
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity)
                    .background(isIPad ? Color(.systemGray6) : Color.clear)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingGoalSelection) {
            GoalSelectionView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(playerName: gameState.currentPlayer.name)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Rectangle()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Posts Tab View
struct PostsTabView: View {
    let posts: [Post]
    @EnvironmentObject var gameState: GameState
    @State private var postContent: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isLoadingImages = false
    
    var body: some View {
        LazyVStack(spacing: 0) {
            // Compose Section
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    if let profileImage = gameState.getProfileImage() {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 12) {
                        TextField("Start a thread...", text: $postContent, axis: .vertical)
                            .lineLimit(4...8)
                            .textFieldStyle(.plain)
                            .font(.body)
                        
                        HStack {
                            PhotosPicker(selection: $selectedItems,
                                       maxSelectionCount: 4,
                                       matching: .images,
                                       photoLibrary: .shared()) {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                            .onChange(of: selectedItems) { _, newItems in
                                Task {
                                    isLoadingImages = true
                                    selectedImages = []
                                    
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            await MainActor.run {
                                                selectedImages.append(image)
                                            }
                                        }
                                    }
                                    
                                    await MainActor.run {
                                        isLoadingImages = false
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        
                        if isLoadingImages {
                            ProgressView()
                                .padding(.top, 8)
                        } else if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 200)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            Button {
                                                removeImage(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.black.opacity(0.5)))
                                            }
                                            .padding(8)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                }
            }
            .padding()
            
            if !postContent.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        createPost()
                    } label: {
                        Text("Post")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .cornerRadius(20)
                    }
                    .disabled(isLoadingImages)
                    .padding(.trailing)
                    .padding(.bottom)
                }
            }
            
            // Border between compose and posts
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.top, 8)
            
            // Posts List
            if posts.isEmpty {
                Text("No posts yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(posts.sorted(by: { $0.timestamp > $1.timestamp })) { post in
                    PostRowView(post: post)
                }
            }
        }
    }
    
    private func removeImage(at index: Int) {
        selectedImages.remove(at: index)
        selectedItems.remove(at: index)
    }
    
    private func createPost() {
        guard !postContent.isEmpty else { return }
        guard !isLoadingImages else { return }
        
        // Create profile from player if it doesn't exist
        if gameState.profile == nil {
            gameState.profile = Profile(
                name: gameState.currentPlayer.name,
                role: gameState.currentPlayer.role,
                goal: gameState.playerGoal ?? .retirement
            )
        }
        
        // Convert images to strings
        let imageStrings = selectedImages.compactMap { image -> String? in
            guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
            return data.base64EncodedString()
        }
        
        let newPost = Post(
            author: gameState.currentPlayer.handle ?? gameState.currentPlayer.name,
            role: gameState.currentPlayer.role,
            content: postContent,
            images: imageStrings,
            isAutoGenerated: false
        )
        
        // Add post and save state
        gameState.addPost(newPost)
        gameState.saveState()
        
        // Clear the form
        postContent = ""
        selectedItems = []
        selectedImages = []
    }
}

// MARK: - Goals Tab View
struct GoalsTabView: View {
    let goal: Goal?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let goal = goal {
                VStack(alignment: .leading, spacing: 12) {
                    Text(goal.title)
                        .font(.title3)
                        .bold()
                    
                    Text(goal.shortDescription)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("Target:")
                            .foregroundColor(.gray)
                        Text("$\(Int(goal.price).formattedWithSeparator)")
                            .bold()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("No goals set")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top)
    }
}

// MARK: - Investments Tab View
struct InvestmentsTabView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Startups")
                .font(.headline)
                .padding(.horizontal)
            
            if gameState.activeBusinesses.isEmpty {
                Text("No startups yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(gameState.activeBusinesses) { business in
                    Text(business.title)
                        .font(.body)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.top)
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameState())
} 