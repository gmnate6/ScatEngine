import Foundation

public struct Player: Identifiable {
    public let id: UUID
    public let name: String
    public internal(set) var cards: [Card]

    public internal(set) var chips: Int {
        didSet {
            if chips < 0 {
                chips = 0
            }
        }
    }

    public var isEliminated: Bool {
        chips == 0
    }
    
    public var isAlive: Bool {
        !isEliminated
    }

    init(name: String, chips: Int) {
        self.id = UUID()
        self.name = name
        self.cards = []
        self.chips = chips
    }

    mutating func addCard(_ card: Card) {
        cards.append(card)
    }
    
    func hasCard(_ card: Card) -> Bool {
        cards.contains(card)
    }

    mutating func removeCard(_ card: Card) throws {
        guard let index = cards.firstIndex(of: card) else {
            throw ScatError.playerDiscardedCardTheyDontHave
        }
        cards.remove(at: index)
    }
    
    mutating func removeCards() {
        cards.removeAll()
    }
}
