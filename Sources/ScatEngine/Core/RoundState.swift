import Foundation

struct RoundState {
    var discardPile: Pile
    var drawPile: Pile
    var currentTurnIndex: Int
    var knockerID: UUID?
    
    var isKnocked: Bool {
        knockerID != nil
    }
    
    init(startingPlayerIndex: Int) {
        self.discardPile = Pile()
        self.drawPile = Pile()
        self.currentTurnIndex = startingPlayerIndex
        self.knockerID = nil
    }
}
