struct Pile {
    private var cards: [Card]

    var count: Int { cards.count }
    var isEmpty: Bool { cards.isEmpty }
    var topCard: Card? { cards.last }

    init(cards: [Card] = []) {
        self.cards = cards
    }

    mutating func draw() -> Card? {
        cards.popLast()
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
