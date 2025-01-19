import Foundation

struct GameEvent: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let effect: (inout Player) -> Void
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         effect: @escaping (inout Player) -> Void) {
        self.id = id
        self.title = title
        self.description = description
        self.effect = effect
    }
} 