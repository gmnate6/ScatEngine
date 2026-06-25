import Testing
@testable import ScatEngine

struct PileTests {
    @Test
    func pileStartsEmpty() {
        let pile = Pile()
        
        #expect(pile.count == 0)
        #expect(pile.isEmpty)
        #expect(pile.topCard == nil)
    }
    
    @Test
    func pileCanBeInitializedWithCards() {
        let cards = [
            Card(rank: .ace, suit: .spades),
            Card(rank: .king, suit: .hearts)
        ]

        let pile = Pile(cards: cards)

        #expect(pile.count == 2)
        #expect(!pile.isEmpty)
        #expect(pile.topCard == cards.last)
    }
    
    @Test
    func addIncreasesCount() {
        var pile = Pile()

        let card = Card(rank: .ace, suit: .spades)

        pile.add(card)

        #expect(pile.count == 1)
        #expect(pile.topCard == card)
    }
    
    @Test
    func drawFromEmptyPileReturnsNil() {
        var pile = Pile()

        let card = pile.draw()

        #expect(card == nil)
        #expect(pile.isEmpty)
    }
    
    @Test
    func clearRemovesAllCards() {
        var pile = Pile(cards: [
            Card(rank: .ace, suit: .spades),
            Card(rank: .king, suit: .hearts)
        ])

        pile.clear()

        #expect(pile.count == 0)
        #expect(pile.isEmpty)
        #expect(pile.topCard == nil)
    }
    
    @Test
    func takeAllReturnsCardsAndEmptiesPile() {
        let cards = [
            Card(rank: .ace, suit: .spades),
            Card(rank: .king, suit: .hearts)
        ]

        var pile = Pile(cards: cards)

        let taken = pile.takeAll()

        #expect(taken == cards)
        #expect(pile.isEmpty)
        #expect(pile.count == 0)
    }
    
    @Test
    func shufflePreservesCardCount() {
        var rng = SeededGenerator(seed: 123)

        let cards = [
            Card(rank: .ace, suit: .spades),
            Card(rank: .king, suit: .hearts),
            Card(rank: .queen, suit: .clubs)
        ]

        var pile = Pile(cards: cards)

        pile.shuffle(using: &rng)

        #expect(pile.count == cards.count)
    }
    
    @Test
    func shuffleIsDeterministicForSeed() {
        let deck = createDeck()
        
        var rng1 = SeededGenerator(seed: 123)
        var rng2 = SeededGenerator(seed: 123)

        var pile1 = Pile(cards: deck)
        var pile2 = Pile(cards: deck)

        pile1.shuffle(using: &rng1)
        pile2.shuffle(using: &rng2)

        #expect(pile1.takeAll() == pile2.takeAll())
    }
}
