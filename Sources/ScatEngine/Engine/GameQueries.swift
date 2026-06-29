enum GameQueries {
    static func isActive(gameState: GameState) -> Bool {
        gameState.players.filter { $0.chips > 0 }.count > 1
    }
    
    static func alivePlayerIndices(in gameState: GameState) -> [Int] {
        gameState.players.indices.filter { gameState.players[$0].isAlive}
    }
    
    static func alivePlayerCount(in gameState: GameState) -> Int {
        gameState.players.filter { $0.isAlive }.count
    }
    
    static func nextAlivePlayerIndex(gameState: GameState, currentIndex: Int) -> Int {
        precondition(alivePlayerCount(in: gameState) > 0, "No active players")
        
        var index = currentIndex
        
        repeat {
            index = (index + 1) % gameState.players.count
        } while !gameState.players[index].isAlive
        
        return index
    }
    
    static func winnerIndex(gameState: GameState) -> Int {
        precondition(!isActive(gameState: gameState), "Game is still active")

        guard let winner = gameState.players.indices.first(where: {
            gameState.players[$0].chips > 0
        }) else {
            preconditionFailure("No winner found")
        }

        return winner
    }
    
    static func hasScat(gameState: GameState) -> Bool {
        for playerIndex in GameQueries.alivePlayerIndices(in: gameState) {
            if Scoring.isScat(player: gameState.players[playerIndex]) {
                return true
            }
        }
        return false
    }

    static func scattersIndices(gameState: GameState) -> [Int] {
        return GameQueries.alivePlayerIndices(in: gameState).filter { Scoring.isScat(player: gameState.players[$0]) }
    }
}
