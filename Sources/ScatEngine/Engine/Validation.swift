func validate(gameState: GameState) throws {
    guard gameState.players.count >= 2 && gameState.players.count <= 8 else {
        throw ValidationError.invalidPlayerCount
    }
    
    guard gameState.isStarted else { return }
    
    guard !gameState.roundState.drawPile.isEmpty else {
        throw ValidationError.emptyDrawPile
    }
    
    guard !gameState.roundState.discardPile.isEmpty else {
        throw ValidationError.emptyDiscardPile
    }
    
    let allCards: [Card] =
    gameState.roundState.drawPile.cards +
    gameState.roundState.discardPile.cards +
    gameState.players.flatMap(\.cards)
    
    guard allCards.count == Set(allCards).count else {
        throw ValidationError.invalidDeck
    }

    guard allCards.count == Deck.standardCount else {
        throw ValidationError.invalidDeck
    }
    
    for i in GameQueries.alivePlayerIndices(in: gameState) {
        guard gameState.players[i].cards.count == 3 else {
            throw ValidationError.invalidHandSize
        }
    }
    
    guard gameState.players[gameState.roundState.currentPlayerIndex].isAlive else {
        throw ValidationError.deadCurrentPlayer
    }
}

func assertValidState(gameState: GameState, context: String = "") {
    do {
        try validate(gameState: gameState)
    } catch {
        fatalError("""
        ScatEngine invariant violation

        Context: \(context)

        Error: \(error)
        """)
    }
}
