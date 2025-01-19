import Foundation
import SwiftUI

class GameState: ObservableObject {
    @Published var currentPlayer: Player
    @Published var events: [GameEvent]
    @Published var eventLog: [String]
    
    init() {
        // Initialize with default player
        self.currentPlayer = Player(
            name: "John Doe",
            role: "Software Developer"
        )
        
        // Initialize empty event log
        self.eventLog = []
        
        // Initialize sample events
        self.events = [
            GameEvent(
                title: "Crypto Surge",
                description: "Your crypto investment doubled!",
                effect: { player in
                    player.bankBalance += 500
                }
            ),
            GameEvent(
                title: "Laptop Repair",
                description: "Your laptop needs urgent repairs.",
                effect: { player in
                    player.bankBalance -= 300
                }
            ),
            GameEvent(
                title: "Overtime Bonus",
                description: "You worked extra hours this month.",
                effect: { player in
                    player.bankBalance += 1000
                }
            ),
            GameEvent(
                title: "Car Maintenance",
                description: "Regular car maintenance due.",
                effect: { player in
                    player.bankBalance -= 200
                }
            )
        ]
    }
    
    func advanceTurn() {
        // Add salary
        currentPlayer.bankBalance += currentPlayer.monthlySalary
        
        // Subtract expenses
        currentPlayer.bankBalance -= currentPlayer.monthlyExpenses
        
        // Pick and apply random event
        if let randomEvent = events.randomElement() {
            randomEvent.effect(&currentPlayer)
            
            // Log the event
            eventLog.insert("\(randomEvent.title): \(randomEvent.description)", at: 0)
        }
    }
    
    func startNewGame(with player: Player) {
        self.currentPlayer = player
        self.eventLog = []  // Clear any existing event log
    }
} 