import Foundation

struct GameEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    private let effectType: EffectType
    
    enum EffectType: String, Codable {
        case addMoney
        case subtractMoney
        case none
    }
    
    var effect: (inout Player) -> Void {
        switch effectType {
        case .addMoney:
            return { player in player.bankBalance += 500 }
        case .subtractMoney:
            return { player in player.bankBalance -= 500 }
        case .none:
            return { _ in }
        }
    }
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         effectType: EffectType = .none) {
        self.id = id
        self.title = title
        self.description = description
        self.effectType = effectType
    }
    
    // Previous initializer for backward compatibility
    init(id: UUID = UUID(),
         title: String,
         description: String,
         effect: @escaping (inout Player) -> Void) {
        self.id = id
        self.title = title
        self.description = description
        self.effectType = .none
        // Note: The custom effect will be lost when serializing
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, effectType
    }
} 