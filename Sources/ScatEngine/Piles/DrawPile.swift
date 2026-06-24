struct DrawPile {
    private var cards: [Card]

    var count: Int { cards.count }
    var isEmpty: Bool { cards.isEmpty }
    var topCard: Card? { cards.last }
    
    init() {
        cards = []
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

    mutating func shuffle(using rng: inout SeededGenerator) {
        cards.shuffle(using: &rng)
    }

    mutating func setCards(_ cards: [Card]) {
        self.cards = cards
    }
}
