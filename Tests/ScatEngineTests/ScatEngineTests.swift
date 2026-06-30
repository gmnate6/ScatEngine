import Testing
@testable import ScatEngine

struct ScatEngineTests {
    @Test
    func initTest() {
        let engine = ScatEngine(seed: 123, playerCount: 4)
        #expect(throws: Never.self) {
            try validate(gameState: engine.gameState)
        }
    }
    
    @Test
    func startGameTest() {
        let engine = ScatEngine(seed: 123, playerCount: 4)
        _ = engine.startGame()
        #expect(throws: Never.self) {
            try validate(gameState: engine.gameState)
        }
    }
    
    @Test
    func legalMovesTest() {
        let engine = ScatEngine(seed: 123, playerCount: 4)
        _ = engine.startGame()
        let moves = engine.legalMoves()
        
        #expect(moves.count == 9) // 1 knock + (2 sources * 4 discards)
        #expect(moves.contains(.knock))
        #expect(moves.contains(.drawAndDiscard(source: .drawPile, discard: engine.topOfDrawPile)))
        #expect(!moves.contains(.drawAndDiscard(source: .drawPile, discard: engine.topOfDiscardPile)))
    }
    
    @Test
    func makeMoveTest() {
        let engine = ScatEngine(seed: 123, playerCount: 2, startingChips: 1)
        _ = engine.startGame()
        
        // p0
        #expect(throws: Never.self) {
            try _ = engine.makeMove(.knock)
        }

        // p1 + knockresolution
        #expect(throws: Never.self) {
            try _ = engine.makeMove(.drawAndDiscard(source: .drawPile, discard: engine.currentPlayer.cards.first!))
        }
        
        let p0_score = Scoring.score(of: engine.players[0])
        let p1_score = Scoring.score(of: engine.players[1])
        if p0_score > p1_score {
            // p0 won
            #expect(engine.winnerIndex == 0)
        } else {
            // p0 won
            #expect(engine.winnerIndex == 1)
        }
    }
}
