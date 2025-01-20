import SwiftUI

struct InvestmentOpportunityView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    @State private var quantity: String = ""
    
    var asset: Asset? {
        post.linkedInvestment
    }
    
    var totalCost: Double {
        (Double(quantity) ?? 0) * (asset?.currentPrice ?? 0)
    }
    
    var canAfford: Bool {
        gameState.currentPlayer.bankBalance >= totalCost
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(post.author)
                                .font(.headline)
                            Text(post.role)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        if post.isSponsored {
                            Text("Sponsored")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(uiColor: .systemGray6))
                                .cornerRadius(4)
                        }
                    }
                    
                    // Investment Details
                    if let asset = asset {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(asset.name)
                                .font(.title2)
                                .bold()
                            
                            Text("Current Price: \(asset.currentPrice, format: .currency(code: "USD"))")
                                .font(.headline)
                            
                            Divider()
                            
                            // Purchase Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Amount to Purchase:")
                                    .font(.headline)
                                
                                TextField("Enter quantity", text: $quantity)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                if !quantity.isEmpty {
                                    Text("Total Cost: \(totalCost, format: .currency(code: "USD"))")
                                        .foregroundColor(canAfford ? .primary : .red)
                                        .font(.headline)
                                }
                                
                                if !canAfford && !quantity.isEmpty {
                                    Text("Insufficient funds")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            if let asset = asset {
                                if asset.type == .crypto {
                                    gameState.buyCrypto(
                                        symbol: asset.symbol,
                                        name: asset.name,
                                        quantity: Double(quantity) ?? 0,
                                        price: asset.currentPrice
                                    )
                                } else {
                                    gameState.buyStock(
                                        symbol: asset.symbol,
                                        name: asset.name,
                                        quantity: Double(quantity) ?? 0,
                                        price: asset.currentPrice
                                    )
                                }
                                dismiss()
                            }
                        }) {
                            Text("Buy Now")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canAfford ? Color.blue : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!canAfford || quantity.isEmpty)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

#Preview {
    InvestmentOpportunityView(post: Post.example)
        .environmentObject(GameState())
} 