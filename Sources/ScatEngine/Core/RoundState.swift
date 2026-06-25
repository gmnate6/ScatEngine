import Foundation

struct RoundState {
    var discardPile: Pile
    var drawPile: Pile
    var currentTurnIndex: Int
    var isKnocked: Bool
    var knockerID: UUID?
    
    init(startingPlayerIndex: Int) {
        self.discardPile = Pile()
        self.drawPile = Pile()
        self.currentTurnIndex = startingPlayerIndex
        self.isKnocked = false
        self.knockerID = nil
    }
}
