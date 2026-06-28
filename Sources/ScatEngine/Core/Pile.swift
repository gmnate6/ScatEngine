struct Pile: Codable {
    var cards: [Card]

    var count: Int { cards.count }
    var isEmpty: Bool { cards.isEmpty }
    var topCard: Card {
        precondition(!cards.isEmpty, "Cannot get topCard from an empty pile")
        return cards.last!
    }

    init(cards: [Card] = []) {
        self.cards = cards
    }

    mutating func draw() -> Card {
        precondition(!cards.isEmpty, "Can't draw from an empty pile")
        return cards.popLast()!
    }

    mutating func add(_ card: Card) {
        cards.append(card)
    }

    mutating func clear() {
        cards.removeAll()
    }

    mutating func takeAll() -> [Card] {
        defer { cards.removeAll() }
        return cards
    }

    mutating func shuffle(using rng: inout SeededGenerator) {
        cards.shuffle(using: &rng)
    }
}
