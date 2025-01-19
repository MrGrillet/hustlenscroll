import SwiftUI

struct FeedView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack {
            Text("Event Log")
                .font(.largeTitle)
                .padding()
            
            List {
                ForEach(gameState.eventLog, id: \.self) { event in
                    Text(event)
                        .padding(.vertical, 8)
                }
            }
        }
    }
} 