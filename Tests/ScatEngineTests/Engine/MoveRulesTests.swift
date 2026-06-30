import Testing
@testable import ScatEngine

struct MoveRulesTests {
    @Test
    func canKnockTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        #expect(MoveRules.canKnock(gameState: gameState))
        
        gameState.roundState.knockingPlayerIndex = 0
        
        #expect(!MoveRules.canKnock(gameState: gameState))
    }
    
    @Test
    func legalDiscardsTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        dealDeck(gameState: &gameState)
        
        let discards = MoveRules.legalDiscards(for: .drawPile, in: gameState)
        #expect(discards.count == 4)
        #expect(discards.contains(gameState.roundState.drawPile.topCard))
        
        let playerCards = gameState.players[gameState.roundState.currentPlayerIndex].cards
        #expect(Set(playerCards).isSubset(of: Set(discards)))
    }
    
    @Test
    func moveValidation_gameNotStarted() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        let gameState = GameState(rng: rng, players: [p0, p1])
        
        let move: Move = .knock
        #expect(throws: ScatError.gameNotStarted) {
            try MoveRules.validate(move: move, in: gameState)
        }
    }
    
    @Test
    func moveValidation_gameOver() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        gameState.players[1].chips = 0
        
        let move: Move = .knock
        #expect(throws: ScatError.gameOver) {
            try MoveRules.validate(move: move, in: gameState)
        }
    }
    
    @Test
    func moveValidation_alreadyKnocked() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        gameState.roundState.knockingPlayerIndex = 1
        
        let move: Move = .knock
        #expect(throws: ScatError.alreadyKnocked) {
            try MoveRules.validate(move: move, in: gameState)
        }
    }
    
    @Test
    func moveValidation_invalidDiscard() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        
        let nonDrawPileCard = gameState.players[1].cards.first // Can't be in draw pile
        let move: Move = .drawAndDiscard(source: .drawPile, discard: nonDrawPileCard!)
        do {
            try MoveRules.validate(move: move, in: gameState)
            Issue.record("Expected error but none thrown")
        } catch let error as ScatError {
            guard case .invalidDiscard = error else {
                Issue.record("Wrong ScatError: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected non-ScatError: \(error)")
        }
    }
    
    @Test
    func moveValidation_validKnockMove() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        
        let move: Move = .knock
        #expect(throws: Never.self) {
            try MoveRules.validate(move: move, in: gameState)
        }
    }

    @Test
    func moveValidation_validDrawAndDiscardMove() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        _ = GameFlow.startGame(gameState: &gameState)
        
        let card: Card = gameState.roundState.drawPile.topCard
        let move: Move = .drawAndDiscard(source: .drawPile, discard: card)
        #expect(throws: Never.self) {
            try MoveRules.validate(move: move, in: gameState)
        }
    }
}
