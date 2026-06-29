import Testing
@testable import ScatEngine

struct KnockingLogicTests {
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
        
        _ = handleScat(gameState: &gameState)
        
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
        
        _ = handleScat(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 2)
    }

    @Test
    func handleKnockResolution_knockerHasHighestOneHasLowest() {
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
        gameState.roundState.knockingPlayerIndex = 0
        gameState.roundState.currentPlayerIndex = 0
        
        _ = handleKnockResolution(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 2)
    }
    
    @Test
    func handleKnockResolution_knockerHasHighestTwoHasLowest() {
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
        gameState.roundState.knockingPlayerIndex = 0
        gameState.roundState.currentPlayerIndex = 0

        _ = handleKnockResolution(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 2)
        #expect(gameState.players[2].chips == 2)
    }
    
    @Test
    func handleKnockResolution_resolveKnock_knockerHasLowest() {
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
        gameState.roundState.knockingPlayerIndex = 2
        gameState.roundState.currentPlayerIndex = 2

        _ = handleKnockResolution(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 1)
    }
    
    @Test
    func handleKnockResolution_knockerTiedForLowest() {
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
        gameState.roundState.knockingPlayerIndex = 2
        gameState.roundState.currentPlayerIndex = 2

        _ = handleKnockResolution(gameState: &gameState)
        
        #expect(gameState.players[0].chips == 3)
        #expect(gameState.players[1].chips == 3)
        #expect(gameState.players[2].chips == 1)
    }
}
