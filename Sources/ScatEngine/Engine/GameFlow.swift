enum GameFlow {
    static func startGame(gameState: inout GameState) -> [GameEvent] {
        gameState.moveNumber = 1
        gameState.roundNumber = 0
        gameState.isStarted = true
        
        var events: [GameEvent] = []
        
        events.append(.gameStarted)
        events += startRound(gameState: &gameState)
        return events
    }
    
    static func startRound(gameState: inout GameState) -> [GameEvent] {
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
    
    static func endRound(gameState: inout GameState) -> [GameEvent] {
        var events: [GameEvent] = []
        events.append(.roundEnded)
        
        let newIndex = GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: gameState.startingPlayerIndex)

        guard GameQueries.isActive(gameState: gameState) else {
            gameState.roundState.currentPlayerIndex = newIndex // current player is never dead
            events.append(endGame(gameState: &gameState))
            return events
        }
        
        gameState.startingPlayerIndex = newIndex
        gameState.roundState = RoundState(startingPlayerIndex: newIndex)
        
        return events
    }
    
    static func endGame(gameState: inout GameState) -> GameEvent {
        precondition(!GameQueries.isActive(gameState: gameState))
        return .gameEnded(
            winnerIndex: GameQueries.winnerIndex(gameState: gameState)
        )
    }
}
