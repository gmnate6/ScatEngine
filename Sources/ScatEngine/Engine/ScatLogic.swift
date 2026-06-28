func gameHasScat(gameState: GameState) -> Bool {
    for playerIndex in alivePlayerIndices(in: gameState) {
        if Scoring.isScat(player: gameState.players[playerIndex]) {
            return true
        }
    }
    return false
}

func getScattersIndices(gameState: GameState) -> [Int] {
    return alivePlayerIndices(in: gameState).filter { Scoring.isScat(player: gameState.players[$0]) }
}

func handleScat(gameState: inout GameState, onDeal: Bool = false) -> [GameEvent] {
    let scatters = getScattersIndices(gameState: gameState)
    precondition(!scatters.isEmpty, "Called handleScat but no scat exists")
    
    var events: [GameEvent] = []
    var losers: [Int] = []
    var eliminated: [Int] = []
    
    for i in gameState.players.indices {
        guard gameState.players[i].isAlive else { continue }
        guard !scatters.contains(i) else { continue }
        
        gameState.players[i].chips -= 1
        losers.append(i)
        if !gameState.players[i].isAlive {
            eliminated.append(i)
        }
    }
    
    events.append(.scat(
        scatters: scatters,
        losers: losers,
        onDeal: onDeal
    ))
    if !eliminated.isEmpty {
        events.append(.playersEliminated(playerIndices: eliminated))
    }
    
    return events
}
