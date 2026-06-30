import Testing
@testable import ScatEngine

func makeEngine() -> ScatEngine {
    let engine = ScatEngine(seed: 1234, playerCount: 3, startingChips: 3)
    _ = engine.startGame()
    return engine
}

struct ScatEngineSerializerTests {
    @Test
    func encodeDecode_roundTrip_preservesState() throws {
        let engine = makeEngine()
        
        // Deterministic move selection (important for reproducibility)
        let moves = engine.legalMoves()
        let move = moves.first!
        
        _ = try engine.makeMove(move)
        
        // Save + load round trip
        let data = try ScatEngineSerializer.encode(engine)
        let decoded = try ScatEngineSerializer.decode(data)
        
        // Compare deterministic hashes (single source of truth)
        let originalHash = ScatEngineSerializer.hash(engine)
        let decodedHash = ScatEngineSerializer.hash(decoded)
        
        #expect(originalHash == decodedHash)
    }
    
    @Test
    func hash_isDeterministic() throws {
        let engine = makeEngine()

        #expect(
            ScatEngineSerializer.hash(engine) ==
            ScatEngineSerializer.hash(engine)
        )
    }
    
    @Test
    func hash_changesWhenStateChanges() throws {
        let engine = makeEngine()

        let before = ScatEngineSerializer.hash(engine)

        let move = engine.legalMoves().first!
        _ = try engine.makeMove(move)

        let after = ScatEngineSerializer.hash(engine)

        #expect(before != after)
    }
}
