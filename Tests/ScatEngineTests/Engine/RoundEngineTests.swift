import Testing
@testable import ScatEngine

struct RoundEngineTests {
    @Test
    func isGameActiveTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(isGameActive(gameState: gameState))
        
        gameState.players[0].chips = 0
        #expect(!isGameActive(gameState: gameState))
    }
    
    @Test
    func getWinnerTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(getWinner(gameState: gameState) == nil)
        
        gameState.players[0].chips = 0
        #expect(getWinner(gameState: gameState) == p1)
        
        
        gameState.players[1].chips = 0
        #expect(getWinner(gameState: gameState) == nil)
    }
    
    @Test
    func createDeckTest() {
        let deck = createDeck()
        #expect(deck.count == 52)
    }
    
    @Test
    func getActivePlayersTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(getActivePlayers(gameState: gameState).count == 2)
        
        gameState.players[0].chips = 0
        #expect(getActivePlayers(gameState: gameState).count == 1)
        #expect(getActivePlayers(gameState: gameState)[0] == p1)
        
        
        gameState.players[1].chips = 0
        #expect(getActivePlayers(gameState: gameState).count == 0)
    }
    
    @Test
    func findNextAlivePlayerTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(findNextAlivePlayer(gameState: gameState, currentIndex: 0) == 1)
        
        gameState.players[1].chips = 0
        #expect(findNextAlivePlayer(gameState: gameState, currentIndex: 0) == 0)
    }
    
    @Test
    func dealDeck_activePlayersRecieveThreeCards() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        let p2 = Player(name: "p2", chips: 0)
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.players[0].cards.count == 3)
        #expect(gameState.players[1].cards.count == 3)
        #expect(gameState.players[2].cards.count == 0)
    }
    
    @Test
    func dealDeck_drawPileHasCorrectRemainingCount() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        dealDeck(gameState: &gameState)

        let expectedRemaining = 52 - (2 * 3) - 1 // deck - dealt - discard
        #expect(gameState.roundState.drawPile.count == expectedRemaining)
    }
    
    @Test
    func dealDeck_discardPileHasExactlyOneCard() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.roundState.discardPile.count == 1)
    }
    
    @Test
    func dealDeck_previousCardsAreReplaced() {
        let rng = SeededGenerator(seed: 42)
        var p0 = Player(name: "p0", chips: 1)
        p0.addCard(Card(rank: .ace, suit: .hearts)) // give p0 a card before dealing
        var gameState = GameState(rng: rng, players: [p0])
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.players[0].cards.count == 3)
    }
    
    @Test
    func dealDeck_discardPileIsCleared() {
        let rng = SeededGenerator(seed: 42)
        let p0 = Player(name: "p0", chips: 1)
        var gameState = GameState(rng: rng, players: [p0])
        gameState.roundState.discardPile.add(Card(rank: .ace, suit: .hearts))
        gameState.roundState.discardPile.add(Card(rank: .king, suit: .spades))
        
        dealDeck(gameState: &gameState)
        
        #expect(gameState.roundState.discardPile.count == 1) // old cards gone, only the newly dealt one
    }
    
    @Test
    func resolveKnock_knockerHasHighestOneHasLowest() {
        let rng = SeededGenerator(seed: 123)
        
        var p0 = Player(name: "p0", chips: 3)         // score: 30 (highest)
        p0.addCard(Card(rank: .ace, suit: .hearts))   // 11
        p0.addCard(Card(rank: .ten, suit: .hearts))   // 10
        p0.addCard(Card(rank: .nine, suit: .hearts))  // 9

        var p1 = Player(name: "p1", chips: 3)         // score: 15
        p1.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p1.addCard(Card(rank: .seven, suit: .hearts)) // 7
        p1.addCard(Card(rank: .seven, suit: .clubs))  // 7

        var p2 = Player(name: "p2", chips: 3)         // score: 8 (lowest)
        p2.addCard(Card(rank: .eight, suit: .spades)) // 8
        p2.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p2.addCard(Card(rank: .eight, suit: .clubs))  // 8
        
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        // Have p0 knock
        gameState.roundState.knockerID = p0.id
        gameState.roundState.currentTurnIndex = 0
        
        resolveKnock(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 2)
    }
    
    @Test
    func resolveKnock_knockerHasHighestTwoHasLowest() {
        let rng = SeededGenerator(seed: 123)
        
        var p0 = Player(name: "p0", chips: 3)         // score: 30 (highest)
        p0.addCard(Card(rank: .ace, suit: .hearts))   // 11
        p0.addCard(Card(rank: .ten, suit: .hearts))   // 10
        p0.addCard(Card(rank: .nine, suit: .hearts))  // 9

        var p1 = Player(name: "p1", chips: 3)         // score: 8 (lowest)
        p1.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p1.addCard(Card(rank: .seven, suit: .spades)) // 7
        p1.addCard(Card(rank: .seven, suit: .clubs))  // 7

        var p2 = Player(name: "p2", chips: 3)         // score: 8 (lowest)
        p2.addCard(Card(rank: .eight, suit: .spades)) // 8
        p2.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p2.addCard(Card(rank: .eight, suit: .clubs))  // 8
        
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        // Have p0 knock
        gameState.roundState.knockerID = p0.id
        gameState.roundState.currentTurnIndex = 0
        
        resolveKnock(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 2)
        #expect(gameState.players[2].chips == 2)
    }
    
    @Test
    func resolveKnock_resolveKnock_knockerHasLowest() {
        let rng = SeededGenerator(seed: 123)
        
        var p0 = Player(name: "p0", chips: 3)         // score: 30 (highest)
        p0.addCard(Card(rank: .ace, suit: .hearts))   // 11
        p0.addCard(Card(rank: .ten, suit: .hearts))   // 10
        p0.addCard(Card(rank: .nine, suit: .hearts))  // 9

        var p1 = Player(name: "p1", chips: 3)         // score: 15
        p1.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p1.addCard(Card(rank: .seven, suit: .hearts)) // 7
        p1.addCard(Card(rank: .seven, suit: .clubs))  // 7
        
        var p2 = Player(name: "p2", chips: 3)         // score: 8 (lowest)
        p2.addCard(Card(rank: .eight, suit: .spades)) // 8
        p2.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p2.addCard(Card(rank: .eight, suit: .clubs))  // 8
        
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        // Have p2 knock
        gameState.roundState.knockerID = p2.id
        gameState.roundState.currentTurnIndex = 2
        
        resolveKnock(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 1)
    }
    
    @Test
    func resolveKnock_knockerTiedForLowest() {
        let rng = SeededGenerator(seed: 123)
        
        var p0 = Player(name: "p0", chips: 3)         // score: 30 (highest)
        p0.addCard(Card(rank: .ace, suit: .hearts))   // 11
        p0.addCard(Card(rank: .ten, suit: .hearts))   // 10
        p0.addCard(Card(rank: .nine, suit: .hearts))  // 9

        var p1 = Player(name: "p1", chips: 3)         // score: 8 (lowest)
        p1.addCard(Card(rank: .eight, suit: .spades)) // 8
        p1.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p1.addCard(Card(rank: .eight, suit: .clubs))  // 8

        var p2 = Player(name: "p2", chips: 3)         // score: 8 (lowest)
        p2.addCard(Card(rank: .eight, suit: .spades)) // 8
        p2.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p2.addCard(Card(rank: .eight, suit: .clubs))  // 8
        
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        // Have p2 knock
        gameState.roundState.knockerID = p2.id
        gameState.roundState.currentTurnIndex = 2
        
        resolveKnock(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 1)
    }
    
    @Test
    func handleScat_oneHasScat() {
        let rng = SeededGenerator(seed: 123)
        
        var p0 = Player(name: "p0", chips: 3)         // score: 31 (scat)
        p0.addCard(Card(rank: .ace, suit: .hearts))   // 11
        p0.addCard(Card(rank: .ten, suit: .hearts))   // 10
        p0.addCard(Card(rank: .jack, suit: .hearts))  // 10

        var p1 = Player(name: "p1", chips: 3)         // score: 15
        p1.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p1.addCard(Card(rank: .seven, suit: .hearts)) // 7
        p1.addCard(Card(rank: .seven, suit: .clubs))  // 7

        var p2 = Player(name: "p2", chips: 3)         // score: 8
        p2.addCard(Card(rank: .eight, suit: .spades)) // 8
        p2.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p2.addCard(Card(rank: .eight, suit: .clubs))  // 8
        
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        handleScat(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 2)
        #expect(gameState.players[2].chips == 2)
    }
    
    @Test
    func handleScat_manyHaveScat() {
        let rng = SeededGenerator(seed: 123)
        
        var p0 = Player(name: "p0", chips: 3)         // score: 31 (scat)
        p0.addCard(Card(rank: .ace, suit: .hearts))   // 11
        p0.addCard(Card(rank: .ten, suit: .hearts))   // 10
        p0.addCard(Card(rank: .jack, suit: .hearts))  // 10

        var p1 = Player(name: "p1", chips: 3)         // score: 31 (scat)
        p1.addCard(Card(rank: .ace, suit: .hearts))   // 11
        p1.addCard(Card(rank: .ten, suit: .hearts))   // 10
        p1.addCard(Card(rank: .jack, suit: .hearts))  // 10

        var p2 = Player(name: "p2", chips: 3)         // score: 8
        p2.addCard(Card(rank: .eight, suit: .spades)) // 8
        p2.addCard(Card(rank: .eight, suit: .hearts)) // 8
        p2.addCard(Card(rank: .eight, suit: .clubs))  // 8
        
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        handleScat(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 2)
    }
}
