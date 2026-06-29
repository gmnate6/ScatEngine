func startRound(gameState: inout GameState) -> [GameEvent] {
    precondition(GameQueries.isActive(gameState: gameState))

    var events: [GameEvent] = []
    gameState.roundNumber += 1
    events.append(.roundStarted)
    
    dealDeck(gameState: &gameState)
    events.append(.cardsDealt)
    
    if GameQueries.hasScat(gameState: gameState) {
        events.append(contentsOf: handleScat(gameState: &gameState, onDeal: true))
        events.append(contentsOf: endRound(gameState: &gameState))
        if !GameQueries.isActive(gameState: gameState) {
            return events
        }
        events.append(contentsOf: startRound(gameState: &gameState))
    }
    
    return events
}

func endRound(gameState: inout GameState) -> [GameEvent] {
    var events: [GameEvent] = []
    events.append(.roundEnded)
    
    guard GameQueries.isActive(gameState: gameState) else {
        events.append(endGame(gameState: gameState))
        return events
    }

    let newIndex = GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: gameState.startingPlayerIndex)
    gameState.startingPlayerIndex = newIndex
    gameState.roundState = RoundState(startingPlayerIndex: newIndex)
    
    return events
}

func endGame(gameState: GameState) -> GameEvent {
    precondition(!GameQueries.isActive(gameState: gameState))
    return .gameEnded(
        winnerIndex: GameQueries.winnerIndex(gameState: gameState)
    )
}
