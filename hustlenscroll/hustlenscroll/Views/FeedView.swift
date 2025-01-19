import SwiftUI

struct FeedView: View {
    @EnvironmentObject var gameState: GameState
    @State private var posts: [Post] = []
    
    var body: some View {
        NavigationView {
            List {
                if posts.isEmpty {
                    VStack {
                        Spacer()
                            .frame(height: 100)
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Drag down to refresh your feed")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(posts) { post in
                        PostView(post: post)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Feed")
            .refreshable {
                await refreshFeed()
            }
        }
    }
    
    private func refreshFeed() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Generate new posts
        var newPosts: [Post] = []
        
        // Add 1-2 game event posts
        if let eventPost = Post.gameEventPosts.randomElement() {
            newPosts.append(eventPost)
        }
        
        // Add 4-6 filler posts
        let fillerCount = Int.random(in: 4...6)
        let shuffledFillers = Post.fillerPosts.shuffled()
        newPosts.append(contentsOf: shuffledFillers.prefix(fillerCount))
        
        // Shuffle all posts
        posts = newPosts.shuffled()
        
        // Trigger game state update
        gameState.advanceTurn()
    }
}

struct PostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.userHandle)
                .font(.headline)
                .foregroundColor(post.isGameEvent ? .blue : .gray)
            
            Text(post.body)
                .font(.body)
            
            Text("2m")  // Simplified timestamp
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FeedView()
        .environmentObject(GameState())
} 