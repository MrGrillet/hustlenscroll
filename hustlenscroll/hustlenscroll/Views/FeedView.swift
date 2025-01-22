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
                    .listRowInsets(EdgeInsets())
                } else {
                    ForEach(gameState.posts) { post in
                        FeedPostView(post: post)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
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

struct FeedPostView: View {
    let post: Post
    @State private var showingInvestmentDetail = false
    @State private var activeSheet: PostView.ActiveSheet?
    @State private var selectedBusinesses = Set<BusinessOpportunity>()
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Author Info
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
                    HStack {
                        // Author Name and Role
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.author == gameState.currentPlayer.name ? (gameState.currentPlayer.handle ?? post.userHandle) : post.userHandle)
                                .font(.headline)
                            Text(post.role)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Timestamp
                        Text(formatTimestamp(post.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Post Content
                    Text(post.content)
                        .font(.body)
                        .padding(.top, 4)
                    
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
                                            .frame(width: 220, height: 286)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.leading, 4)
                            .padding(.trailing, 12)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // Investment Badge
                    if post.linkedInvestment != nil {
                        BadgeView(text: "Investment Opportunity")
                            .padding(.top, 4)
                    }
                }
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if post.linkedOpportunity != nil || post.linkedInvestment != nil {
                showingInvestmentDetail = true
            } else if post.linkedMarketUpdate != nil {
                // Check if this is a startup update
                if let update = post.linkedMarketUpdate?.updates.first,
                   update.type == .startup {
                    activeSheet = .startupUpdate
                } else {
                    activeSheet = .tradingUpdate
                }
            }
        }
        .sheet(isPresented: $showingInvestmentDetail) {
            InvestmentDetailView(
                investment: post.linkedInvestment,
                showingInvestmentDetail: $showingInvestmentDetail,
                activeSheet: $activeSheet
            )
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .trending:
                TrendingTopicView(post: post)
            case .investmentPurchase, .tradingUpdate:
                TradingView(post: post, activeSheet: $activeSheet)
            case .startupUpdate:
                MarketUpdateView(
                    post: post,
                    activeSheet: $activeSheet,
                    selectedBusinesses: $selectedBusinesses
                )
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(GameState())
} 