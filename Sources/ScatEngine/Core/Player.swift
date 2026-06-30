import Foundation

public struct Player: Codable {
    public internal(set) var cards: [Card]

    public internal(set) var chips: Int {
        didSet {
            if chips < 0 {
                chips = 0
            }
        }
    }

    public var isAlive: Bool {
        chips > 0
    }

    init(chips: Int) {
        self.cards = []
        self.chips = chips
    }

    mutating func addCard(_ card: Card) {
        cards.append(card)
    }
    
    func hasCard(_ card: Card) -> Bool {
        cards.contains(card)
    }

    mutating func removeCard(_ card: Card) {
        guard let index = cards.firstIndex(of: card) else {
            fatalError("Attempted to remove card \(card), but it was not in the player's hand.")
        }
        cards.remove(at: index)
    }
    
    mutating func removeCards() {
        cards.removeAll()
    }
}
