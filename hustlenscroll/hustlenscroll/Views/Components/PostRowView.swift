import SwiftUI

struct PostRowView: View {
    let post: Post
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // Profile Image
                if let profileImage = gameState.getProfileImage(),
                   (post.author == gameState.currentPlayer.name || 
                    post.author == gameState.currentPlayer.handle || 
                    post.author == gameState.profile?.name) {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Author Handle (preserve original casing if user supplied a handle)
                    Text({ () -> String in
                        if let h = gameState.currentPlayer.handle, !h.isEmpty {
                            return h.hasPrefix("@") ? h : "@\(h)"
                        } else {
                            return post.userHandle
                        }
                    }())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    // Post Content
                    Text(post.content)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            
            // Post Images
            if !post.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.images, id: \.self) { imageString in
                            if let data = Data(base64Encoded: imageString),
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 220, height: 260)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.leading, 60) // Account for 40px profile image + 8px spacing + 12px horizontal padding
                    .padding(.trailing, 12)
                }
            }
            
            // Bottom Border
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    PostRowView(post: Post(
        author: "Test User",
        role: "Test Role",
        content: "This is a test post with some content.",
        timestamp: Date(),
        images: []
    ))
    .environmentObject(GameState())
} 