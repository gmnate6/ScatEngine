struct RoundState: Codable {
    var discardPile: Pile
    var drawPile: Pile
    var currentPlayerIndex: Int
    var knockingPlayerIndex: Int?
    
    var isKnocked: Bool {
        knockingPlayerIndex != nil
    }
    
    init(startingPlayerIndex: Int) {
        self.discardPile = Pile()
        self.drawPile = Pile()
        self.currentPlayerIndex = startingPlayerIndex
        self.knockingPlayerIndex = nil
    }
}
