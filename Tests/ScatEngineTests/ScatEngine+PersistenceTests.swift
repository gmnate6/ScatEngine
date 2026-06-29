import Testing
@testable import ScatEngine

func makeEngine() -> ScatEngine {
    let engine = ScatEngine(seed: 1234, players: ["p0", "p1", "p2"], startingChips: 3)
    _ = engine.startGame()
    return engine
}

struct ScatEngine_PersistenceTests {
    @Test
    func encodeDecode_roundTrip_preservesState() throws {
        let engine = makeEngine()
        
        // Deterministic move selection (important for reproducibility)
        let moves = engine.legalMoves()
        let move = moves.first!
        
        _ = try engine.makeMove(move)
        
        // Save + load round trip
        let data = try engine.makeSaveData()
        let decoded = try ScatEngine(data: data)
        
        // Compare deterministic hashes (single source of truth)
        let originalHash = engine.stateHash()
        let decodedHash = decoded.stateHash()
        
        #expect(originalHash == decodedHash)
    }
}
