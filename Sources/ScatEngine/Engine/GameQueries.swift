func isGameActive(gameState: GameState) -> Bool {
    gameState.players.filter { $0.chips > 0 }.count > 1
}

func alivePlayerIndices(in gameState: GameState) -> [Int] {
    gameState.players.indices.filter { gameState.players[$0].isAlive}
}

func alivePlayerCount(in gameState: GameState) -> Int {
    gameState.players.filter { $0.isAlive }.count
}

func nextAlivePlayerIndex(gameState: GameState, currentIndex: Int) -> Int {
    precondition(alivePlayerCount(in: gameState) > 0, "No active players")
    
    var index = currentIndex
    
    repeat {
        index = (index + 1) % gameState.players.count
    } while !gameState.players[index].isAlive
    
    return index
}
