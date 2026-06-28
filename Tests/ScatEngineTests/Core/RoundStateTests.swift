import Testing
@testable import ScatEngine

struct RoundStateTests {
    @Test
    func roundStateInitializesCorrectly() {
        let state = RoundState(startingPlayerIndex: 2)
        
        #expect(state.currentPlayerIndex == 2)
        #expect(state.isKnocked == false)
        #expect(state.knockingPlayerIndex == nil)
        #expect(state.discardPile.isEmpty)
        #expect(state.drawPile.isEmpty)
    }
}
