import Foundation

func isGameActive(gameState: GameState) -> Bool {
    gameState.players.filter { $0.chips > 0 }.count > 1
}

func createDeck() -> [Card] {
    let deck = Suit.allCases.flatMap { suit in
        Rank.allCases.map { rank in Card(rank: rank, suit: suit) }
    }
    return deck
}

func gameHasScat(gameState: GameState) -> Bool {
    for playerIndex in alivePlayerIndices(in: gameState) {
        if Scoring.isScat(player: gameState.players[playerIndex]) {
            return true
        }
    }
    return false
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

func dealDeck(gameState: inout GameState) {
    let deck = createDeck()
    let aliveCount = alivePlayerCount(in: gameState)

    precondition(deck.count >= aliveCount * 3 + 1, "Not enough cards to deal to \(aliveCount) players")

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

func resolveKnock(gameState: inout GameState) -> [GameEvent] {
    precondition(gameState.roundState.isKnocked, "Called resolveKnock when round not in knock state")
    precondition(gameState.roundState.currentPlayerIndex == gameState.roundState.knockingPlayerIndex, "Called resolveKnock for wrong player")

    let knockerIndex = gameState.roundState.currentPlayerIndex
    let alivePlayers = alivePlayerIndices(in: gameState)

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
    
    let deckSize = 52
    guard uniqueCards.count == deckSize else {
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
