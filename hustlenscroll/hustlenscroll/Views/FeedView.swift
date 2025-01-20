import SwiftUI

struct FeedView: View {
    @EnvironmentObject var gameState: GameState
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            List {
                if gameState.posts.isEmpty {
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
                    ForEach(gameState.posts) { post in
                        PostView(post: post)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Feed")
            .refreshable {
                gameState.advanceDay()
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(GameState())
} 