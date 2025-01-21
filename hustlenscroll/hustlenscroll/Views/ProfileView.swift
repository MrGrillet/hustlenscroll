import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showingGoalSelection = false
    @State private var showingSettings = false
    @State private var postContent: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isLoadingImages = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Compose Section
                    VStack(spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            if let profileImage = gameState.getProfileImage() {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(spacing: 12) {
                                TextEditor(text: $postContent)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(alignment: .topLeading) {
                                        if postContent.isEmpty {
                                            Text("What's on your mind?")
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 12)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                
                                HStack {
                                    PhotosPicker(selection: $selectedItems,
                                               maxSelectionCount: 4,
                                               matching: .images,
                                               photoLibrary: .shared()) {
                                        Label("Add Images", systemImage: "photo.on.rectangle.angled")
                                            .foregroundColor(.blue)
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
                                    
                                    if !postContent.isEmpty {
                                        Button {
                                            createPost()
                                        } label: {
                                            Text("Post")
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 8)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        .disabled(isLoadingImages)
                                    }
                                }
                                
                                if isLoadingImages {
                                    ProgressView()
                                        .padding()
                                } else if !selectedImages.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                                ZStack(alignment: .topTrailing) {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    
                                                    Button {
                                                        removeImage(at: index)
                                                    } label: {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                                    }
                                                    .padding(4)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Profile Header
                    VStack(spacing: 12) {
                        if let profileImage = gameState.getProfileImage() {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                        }
                        
                        Text(gameState.currentPlayer.name)
                            .font(.title)
                            .bold()
                        
                        if let handle = gameState.currentPlayer.handle {
                            Text(handle)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Text(gameState.currentPlayer.role)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Posts Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Posts")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if gameState.userPosts.isEmpty {
                            Text("No posts yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(gameState.userPosts) { post in
                                PostView(post: post)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Goal Section
                    if let goal = gameState.playerGoal {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Life Goal")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
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
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    } else {
                        Button("Set Goal") {
                            showingGoalSelection = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Bio Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bio")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        Text(gameState.currentPlayer.biography)
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
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.blue)
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
        
        guard let profile = gameState.profile else {
            print("No profile found - cannot create post")
            return
        }
        
        // Convert images to strings
        let imageStrings = selectedImages.compactMap { image -> String? in
            guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
            return data.base64EncodedString()
        }
        
        let newPost = Post(
            author: profile.name,
            role: profile.role,
            content: postContent,
            linkedOpportunity: nil,
            linkedInvestment: nil,
            images: imageStrings,
            isAutoGenerated: false
        )
        
        // Clear the form before adding the post
        _ = postContent
        postContent = ""
        
        // Clear images
        selectedImages = []
        selectedItems = []
        
        // Add the post
        gameState.addPost(newPost)
        
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameState())
} 