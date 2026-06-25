func isGameActive(gameState: GameState) -> Bool {
    gameState.players.filter { $0.chips > 0 }.count > 1
}

func getWinner(gameState: GameState) -> Player? {
    guard !isGameActive(gameState: gameState) else { return nil }
    return gameState.players.first { $0.chips > 0 }
}

func createDeck() -> [Card] {
    let deck = Suit.allCases.flatMap { suit in
        Rank.allCases.map { rank in Card(rank: rank, suit: suit) }
    }
    return deck
}

func getActivePlayers(gameState: GameState) -> [Player] {
    gameState.players.filter { !$0.isEliminated }
}

func findNextAlivePlayer(gameState: GameState, currentIndex: Int) -> Int {
    var newIndex = currentIndex
    repeat {
        newIndex = (newIndex + 1) % gameState.players.count
    } while gameState.players[newIndex].isEliminated
    return newIndex
}

func dealDeck(gameState: inout GameState) {
    let deck = createDeck()

    let activeCount = gameState.players.filter { !$0.isEliminated }.count
    precondition(deck.count >= activeCount * 3 + 1, "Not enough cards to deal to \(activeCount) players")

    gameState.roundState.drawPile = Pile(cards: deck)
    gameState.roundState.drawPile.shuffle(using: &gameState.rng)

    for i in gameState.players.indices {
        guard !gameState.players[i].isEliminated else { continue }
        gameState.players[i].removeCards()
        for _ in 0..<3 {
            gameState.players[i].addCard(gameState.roundState.drawPile.draw()!)
        }
    }

    gameState.roundState.discardPile.clear()
    gameState.roundState.discardPile.add(gameState.roundState.drawPile.draw()!)
}

func resolveKnock(gameState: inout GameState) {
    let currentPlayerIndex = gameState.roundState.currentTurnIndex
    let currentPlayer = gameState.players[currentPlayerIndex]

    precondition(gameState.roundState.isKnocked, "Called resolveKnock when round not in knock state")
    precondition(currentPlayer.id == gameState.roundState.knockerID, "Called resolveKnock for wrong player")

    let knockerIndex = currentPlayerIndex
    let activePlayers = getActivePlayers(gameState: gameState)
    let lowestScore = activePlayers.map { Scoring.score(of: $0) }.min()!
    let losers = activePlayers.filter { Scoring.score(of: $0) == lowestScore }

    if losers.contains(where: { $0.id == gameState.roundState.knockerID }) {
        // Knocker lost
        gameState.players[knockerIndex].chips -= 2
    } else {
        // Knocker won
        for player in losers {
            if let index = gameState.players.firstIndex(where: { $0.id == player.id }) {
                gameState.players[index].chips -= 1
            } else {
                fatalError("Player \(player.id) not found in game state")
            }
        }
    }

    endRound(gameState: &gameState)
}

func handleScat(gameState: inout GameState) {
    let scatSet = Set(gameState.players.indices.filter { Scoring.isScat(gameState.players[$0]) })

    guard !scatSet.isEmpty else {
        fatalError("handleScat called but no scat exists")
    }

    for i in gameState.players.indices {
        guard !gameState.players[i].isEliminated else { continue }
        guard !scatSet.contains(i) else { continue }
        gameState.players[i].chips -= 1
    }

    endRound(gameState: &gameState)
}

func endRound(gameState: inout GameState) {
    guard isGameActive(gameState: gameState) else { return }

    let newIndex = findNextAlivePlayer(gameState: gameState, currentIndex: gameState.startingPlayerIndex)
    gameState.startingPlayerIndex = newIndex
    gameState.roundState = RoundState(startingPlayerIndex: newIndex)
    dealDeck(gameState: &gameState)

    if hasScat(gameState: gameState) {
        handleScat(gameState: &gameState)
    }
}
