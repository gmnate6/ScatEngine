import Testing
@testable import ScatEngine

struct GameQueriesTests {
    @Test
    func isActiveTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(GameQueries.isActive(gameState: gameState))
        
        gameState.players[0].chips = 0
        #expect(!GameQueries.isActive(gameState: gameState))
    }
    
    @Test
    func alivePlayerIndicesTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(GameQueries.alivePlayerIndices(in: gameState).count == 2)
        
        gameState.players[0].chips = 0
        #expect(GameQueries.alivePlayerIndices(in: gameState).count == 1)
        #expect(GameQueries.alivePlayerIndices(in: gameState)[0] == 1)
        
        gameState.players[1].chips = 0
        #expect(GameQueries.alivePlayerIndices(in: gameState).count == 0)
    }
    
    @Test
    func alivePlayerCountTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(GameQueries.alivePlayerCount(in: gameState) == 2)
        
        gameState.players[0].chips = 0
        #expect(GameQueries.alivePlayerCount(in: gameState) == 1)
        
        gameState.players[1].chips = 0
        #expect(GameQueries.alivePlayerCount(in: gameState) == 0)
    }

    @Test
    func nextAlivePlayerTest_1() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: 0) == 1)
        
        gameState.players[1].chips = 0
        #expect(GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: 0) == 0)
    }
    
    @Test
    func nextAlivePlayerTest_2() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])

        #expect(GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: 0) == 1)
        
        gameState.players[0].chips = 0
        #expect(GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: 0) == 1)
    }

    @Test
    func hasScatTest() {
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
        
        let gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        #expect(GameQueries.hasScat(gameState: gameState))
    }
    
    @Test
    func scattersIndicesTest() {
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
        
        let gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        #expect(GameQueries.scattersIndices(gameState: gameState) == [0])
    }
}
