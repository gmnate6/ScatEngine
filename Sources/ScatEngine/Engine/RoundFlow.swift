func startRound(gameState: inout GameState) -> [GameEvent] {
    assert(isGameActive(gameState: gameState))

    var events: [GameEvent] = []
    events.append(.roundStarted)
    
    dealDeck(gameState: &gameState)
    events.append(.cardsDealt)
    
    if gameHasScat(gameState: gameState) {
        events.append(contentsOf: handleScat(gameState: &gameState, onDeal: true))
        events.append(endRound(gameState: &gameState))
        events.append(contentsOf: startRound(gameState: &gameState))
    }
    
    return events
}

func endRound(gameState: inout GameState) -> GameEvent {
    assert(isGameActive(gameState: gameState))

    let newIndex = nextAlivePlayerIndex(gameState: gameState, currentIndex: gameState.startingPlayerIndex)
    gameState.startingPlayerIndex = newIndex
    gameState.roundState = RoundState(startingPlayerIndex: newIndex)
    
    return GameEvent.roundEnded
}
