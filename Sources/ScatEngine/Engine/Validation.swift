func validate(gameState: GameState) throws {
    guard gameState.players.count >= 2 && gameState.players.count <= 8 else {
        throw ValidationError.invalidPlayerCount
    }
    
    guard gameState.hasStarted else { return }
    
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
    
    let uniqueCards = Set(allCards)
    
    guard uniqueCards.count == Deck.standardCount else {
        throw ValidationError.invalidDeck
    }
    
    guard gameState.players[gameState.roundState.currentPlayerIndex].isAlive else {
        throw ValidationError.deadCurrentPlayer
    }
    
    if let knockedPlayerIndex = gameState.roundState.knockingPlayerIndex {
        guard gameState.players[knockedPlayerIndex].isAlive else {
            throw ValidationError.deadKnockingPlayer
        }
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
