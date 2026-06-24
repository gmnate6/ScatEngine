import Foundation

struct RoundState {
    var discardPile: DiscardPile
    var drawPile: DrawPile
    var currentTurnIndex: Int
    var isKnocked: Bool
    var knockerID: UUID?
    
    init(startingPlayerIndex: Int) {
        self.discardPile = DiscardPile()
        self.drawPile = DrawPile()
        self.currentTurnIndex = startingPlayerIndex
        self.isKnocked = false
        self.knockerID = nil
    }
}
