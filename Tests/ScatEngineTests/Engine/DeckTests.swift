import Testing
@testable import ScatEngine

struct DeckTests {
    @Test
    func createDeckTest() {
        let deck = Deck.create()
        #expect(deck.count == Deck.standardCount)
    }
    
    @Test
    func dealDeck_activePlayersRecieveThreeCards() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        let p2 = Player(chips: 0)
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.players[0].cards.count == 3)
        #expect(gameState.players[1].cards.count == 3)
        #expect(gameState.players[2].cards.count == 0)
    }
    
    @Test
    func dealDeck_drawPileHasCorrectRemainingCount() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        dealDeck(gameState: &gameState)

        let expectedRemaining = 52 - (2 * 3) - 1 // deck - dealt - discard
        #expect(gameState.roundState.drawPile.count == expectedRemaining)
    }
    
    @Test
    func dealDeck_discardPileHasExactlyOneCard() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.roundState.discardPile.count == 1)
    }
    
    @Test
    func dealDeck_previousCardsAreReplaced() {
        let rng = SeededGenerator(seed: 42)
        var p0 = Player(chips: 1)
        p0.addCard(Card(rank: .ace, suit: .hearts)) // give p0 a card before dealing
        var gameState = GameState(rng: rng, players: [p0])
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.players[0].cards.count == 3)
    }
    
    @Test
    func dealDeck_discardPileIsCleared() {
        let rng = SeededGenerator(seed: 42)
        let p0 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0])
        gameState.roundState.discardPile.add(Card(rank: .ace, suit: .hearts))
        gameState.roundState.discardPile.add(Card(rank: .king, suit: .spades))
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.roundState.discardPile.count == 1) // old cards gone, only the newly dealt one
    }
}
