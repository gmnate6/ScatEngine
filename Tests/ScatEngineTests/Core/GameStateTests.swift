import Testing
@testable import ScatEngine

struct GameStateTests {
    @Test
    func gameStateInitializesCorrectly() {
        let rng = SeededGenerator(seed: 123)

        let players = [
            Player(name: "A", chips: 100),
            Player(name: "B", chips: 100)
        ]

        let state = GameState(rng: rng, players: players)

        #expect(state.players.count == 2)
        #expect(state.startingPlayerIndex == 0)
        #expect(state.roundState.currentPlayerIndex == 0)
        #expect(state.roundState.isKnocked == false)
        #expect(state.roundState.knockingPlayerIndex == nil)
    }
}
