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

        // Do a deterministic move (IMPORTANT: avoid randomness)
        let moves = engine.legalMoves()
        let move = moves.first!

        _ = try engine.makeMove(move)

        let data = try engine.encode()
        let decoded = try ScatEngine(data: data)

        // Compare hashes (best high-level equality check)
        let originalHash = try engine.stateHash()
        let decodedHash = try decoded.stateHash()

        #expect(originalHash == decodedHash)    }
}
