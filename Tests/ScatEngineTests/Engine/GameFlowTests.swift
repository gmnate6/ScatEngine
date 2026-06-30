import Testing
@testable import ScatEngine

struct RoundFlowTests {
    @Test
    func startGameTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        let events = GameFlow.startGame(gameState: &gameState)
        
        #expect(gameState.isStarted)
        #expect(events.contains(.gameStarted))
    }
    
    @Test
    func startRoundTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        let events = GameFlow.startRound(gameState: &gameState)
        
        #expect(events.contains(.roundStarted))
        #expect(events.contains(.cardsDealt))
    }
    
    @Test
    func endRoundTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 0)
        let p1 = Player(chips: 1)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        let events = GameFlow.endRound(gameState: &gameState)
        
        #expect(events.contains(.roundEnded))
    }
    
    @Test
    func endGameTest() {
        let rng = SeededGenerator(seed: 123)
        let p0 = Player(chips: 1)
        let p1 = Player(chips: 0)
        var gameState = GameState(rng: rng, players: [p0, p1])
        
        let events = GameFlow.endGame(gameState: &gameState)
        
        #expect(events == .gameEnded(winnerIndex: 0))
    }
}
