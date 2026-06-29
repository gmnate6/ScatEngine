enum EventHandlers {
    static func handleScat(gameState: inout GameState, onDeal: Bool = false) -> [GameEvent] {
        let scatters = GameQueries.scattersIndices(gameState: gameState)
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
    
    static func handleKnockResolution(gameState: inout GameState) -> [GameEvent] {
        precondition(gameState.roundState.isKnocked, "Called resolveKnock when round not in knock state")
        precondition(gameState.roundState.currentPlayerIndex == gameState.roundState.knockingPlayerIndex, "Called resolveKnock for wrong player")
        
        let knockerIndex = gameState.roundState.currentPlayerIndex
        let alivePlayers = GameQueries.alivePlayerIndices(in: gameState)
        
        let playerScores = alivePlayers.map { index in
            (index: index, score: Scoring.score(of: gameState.players[index]))
        }
        
        let lowestScore = playerScores.map(\.score).min()!
        let losingPlayers = playerScores.filter { $0.score == lowestScore }.map(\.index)
        let knockerLost = losingPlayers.contains(knockerIndex)
        
        var eliminated: [Int] = []
        let knockResult: GameEvent.KnockResults
        if knockerLost {
            // Knocker pays double when they hold the lowest hand
            gameState.players[knockerIndex].chips -= 2
            if !gameState.players[knockerIndex].isAlive {
                eliminated.append(knockerIndex)
            }
            knockResult = .knockerLost
        } else {
            for loserIndex in losingPlayers {
                gameState.players[loserIndex].chips -= 1
                if !gameState.players[loserIndex].isAlive {
                    eliminated.append(loserIndex)
                }
            }
            knockResult = .knockerWon(losers: losingPlayers)
        }
        
        var events: [GameEvent] = [
            .knockResolved(knockerIndex: knockerIndex, results: knockResult)
        ]
        if !eliminated.isEmpty {
            events.append(.playersEliminated(playerIndices: eliminated))
        }
        return events
    }
}
