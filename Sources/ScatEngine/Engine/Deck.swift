enum Deck {
    static let standardCount = 52
    static func create() -> [Card] {
        Suit.allCases.flatMap { suit in
            Rank.allCases.map { rank in Card(rank: rank, suit: suit) }
        }
    }
}

func dealDeck(gameState: inout GameState) {
    let deck = Deck.create()
    let aliveCount = alivePlayerCount(in: gameState)
    precondition(deck.count >= aliveCount * 3 + 1, "Not enough cards...")
    
    gameState.roundState.drawPile = Pile(cards: deck)
    gameState.roundState.drawPile.shuffle(using: &gameState.rng)
    
    for i in gameState.players.indices {
        gameState.players[i].removeCards()
        guard gameState.players[i].isAlive else { continue }
        for _ in 0..<3 {
            gameState.players[i].addCard(gameState.roundState.drawPile.draw())
        }
    }
    
    gameState.roundState.discardPile.clear()
    gameState.roundState.discardPile.add(gameState.roundState.drawPile.draw())
}
