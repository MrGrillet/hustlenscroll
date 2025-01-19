import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BankView()
                .tabItem {
                    Label("Bank", systemImage: "dollarsign.circle")
                }
            
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
        }
    }
} 