import Testing
@testable import ScatEngine

struct ValidationTests {
    @Test
    func gameValidate_invlidPlayerCount_toFew() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let gameState = GameState(rng: rng, players: [p0])
        
        #expect(throws: ValidationError.invalidPlayerCount) {
            try validate(gameState: gameState)
        }
    }
    
    @Test
    func gameValidate_invlidPlayerCount_toMany() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        let p2 = Player(name: "p2", chips: 1)
        let p3 = Player(name: "p3", chips: 1)
        let p4 = Player(name: "p4", chips: 1)
        let p5 = Player(name: "p5", chips: 1)
        let p6 = Player(name: "p6", chips: 1)
        let p7 = Player(name: "p7", chips: 1)
        let p8 = Player(name: "p8", chips: 1)
        let gameState = GameState(rng: rng, players: [p0, p1, p2, p3, p4, p5, p6, p7, p8])
        
        #expect(throws: ValidationError.invalidPlayerCount) {
            try validate(gameState: gameState)
        }
    }
    
    @Test
    func gameValidate_emptyDrawPile() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        gameState.roundState.drawPile.cards.removeAll()

        #expect(throws: ValidationError.emptyDrawPile) {
            try validate(gameState: gameState)
        }
    }
    
    @Test
    func gameValidate_emptyDiscardPile() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        gameState.roundState.discardPile.cards.removeAll()

        #expect(throws: ValidationError.emptyDiscardPile) {
            try validate(gameState: gameState)
        }
    }

    @Test
    func gameValidate_invlidDeck_toFew() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        gameState.players[0].cards.removeLast()

        #expect(throws: ValidationError.invalidDeck) {
            try validate(gameState: gameState)
        }
    }
    
    @Test
    func gameValidate_invlidDeck_toMany() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        gameState.roundState.discardPile.cards.append(Card(rank: .ace, suit: .spades))
        
        #expect(throws: ValidationError.invalidDeck) {
            try validate(gameState: gameState)
        }
    }
    
    @Test
    func gameValidate_invalidHandSize() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        let card = gameState.roundState.drawPile.draw()
        gameState.players[0].addCard(card)
        
        #expect(throws: ValidationError.invalidHandSize) {
            try validate(gameState: gameState)
        }
    }
    
    @Test
    func gameValidate_deadCurrentPlayer() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 1)
        let p1 = Player(name: "p1", chips: 1)
        let p2 = Player(name: "p2", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1, p2])
        
        _ = GameFlow.startGame(gameState: &gameState)
        gameState.players[gameState.roundState.currentPlayerIndex].chips = 0
        
        #expect(throws: ValidationError.deadCurrentPlayer) {
            try validate(gameState: gameState)
        }
    }
    
    @Test
    func gameValidate_validGameState() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(name: "p0", chips: 3)
        let p1 = Player(name: "p1", chips: 1)
        let p2 = Player(name: "p2", chips: 0)
        let p3 = Player(name: "p3", chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1, p2, p3])
        
        _ = GameFlow.startGame(gameState: &gameState)
        
        #expect(throws: Never.self) {
            try validate(gameState: gameState)
        }
    }
}
