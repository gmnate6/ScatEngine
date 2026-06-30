public class ScatEngine {
    var gameState: GameState
    
    public var topOfDiscardPile: Card {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.discardPile.topCard
    }
    
    public var topOfDrawPile: Card {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.drawPile.topCard
    }
    
    public var drawPileSize: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.drawPile.count
    }
    
    public var discardPileSize: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.discardPile.count
    }
    
    public var players: [Player] {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.players
    }
    
    public var alivePlayers: [Player] {
        precondition(gameState.isStarted, "Must call startGame() first")
        return GameQueries.alivePlayerIndices(in: gameState).map { gameState.players[$0] }
    }
    
    public var currentPlayerIndex: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.currentPlayerIndex
    }
    
    public var currentPlayer: Player {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.players[gameState.roundState.currentPlayerIndex]
    }
    
    public var currentPlayerHand: [Card] {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.players[gameState.roundState.currentPlayerIndex].cards
    }
    
    public var canKnock: Bool {
        precondition(gameState.isStarted, "Must call startGame() first")
        return MoveRules.canKnock(gameState: gameState)
    }
    
    public var isKnocked: Bool {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.isKnocked
    }
    
    public var knockingPlayerIndex: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        precondition(gameState.roundState.isKnocked)
        return gameState.roundState.knockingPlayerIndex!
    }
    
    public var winnerIndex: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        precondition(!GameQueries.isActive(gameState: gameState))
        return GameQueries.winnerIndex(gameState: gameState)
    }
    
    public var winner: Player {
        precondition(gameState.isStarted, "Must call startGame() first")
        precondition(!GameQueries.isActive(gameState: gameState))
        return gameState.players[GameQueries.winnerIndex(gameState: gameState)]
    }
    
    public var isStarted: Bool {
        return gameState.isStarted
    }
    
    public var isActive: Bool {
        guard gameState.isStarted else { return false }
        return GameQueries.isActive(gameState: gameState)
    }
    
    public var moveNumber: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.moveNumber
    }
    
    public var roundNumber: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.moveNumber
    }

    public init(seed: UInt64, players: [String], startingChips: Int = 3) {
        precondition(players.count >= 2 && players.count <= 8, "Player count must be between 2 and 8, got \(players.count)")
        precondition(startingChips > 0, "Starting chips must be greater than 0")
        
        let playerObjs: [Player] = players.map { name in
            Player(name: name, chips: startingChips)
        }
        
        gameState = GameState(rng: SeededGenerator(seed: seed), players: playerObjs)
    }
    
    init(gameState: GameState) throws {
        try validate(gameState: gameState)
        self.gameState = gameState
    }
    
    public func startGame() -> [GameEvent] {
        precondition(!gameState.isStarted, "Must call startGame() first")
        return GameFlow.startGame(gameState: &gameState)
    }
    
    public func legalMoves() -> [Move] {
        precondition(gameState.isStarted, "Cannot query moves before startGame()")
        precondition(GameQueries.isActive(gameState: gameState), "Cannot query moves after game over")
        
        var moves: [Move] = []
        
        // Knocking
        if MoveRules.canKnock(gameState: gameState) {
            moves.append(.knock)
        }

        // Draw and discard
        for source in DrawSource.allCases {
            for discard in MoveRules.legalDiscards(for: source, in: gameState) {
                moves.append(.drawAndDiscard(source: source, discard: discard))
            }
        }
        return moves
    }
    
    public func makeMove(_ move: Move) throws -> [GameEvent] {
        try MoveRules.validate(move: move, in: gameState)
        let currentPlayerIndex = gameState.roundState.currentPlayerIndex
        
        defer {
            assertValidState(gameState: gameState, context: "after makeMove(\(move))")
        }
        
        gameState.moveNumber += 1
        
        var events: [GameEvent] = []
        
        switch move {
        case .knock:
            gameState.roundState.knockingPlayerIndex = currentPlayerIndex
            events.append(.playerKnocked(playerIndex: currentPlayerIndex))
            
        case let .drawAndDiscard(source, discard):
            // Draw Card
            let card: Card = switch source {
            case .drawPile:   gameState.roundState.drawPile.draw()
            case .discardPile: gameState.roundState.discardPile.draw()
            }
            
            // Add to player
            gameState.players[currentPlayerIndex].addCard(card)
            events.append(.playerDrew(playerIndex: currentPlayerIndex, card: card, source: source))
            
            // Reshuffle
            if gameState.roundState.drawPile.isEmpty {
                gameState.roundState.drawPile = Pile(cards: gameState.roundState.discardPile.takeAll())
                gameState.roundState.drawPile.shuffle(using: &gameState.rng)
                events.append(.drawPileReshuffled)
            }

            // Discard
            gameState.players[currentPlayerIndex].removeCard(discard)
            gameState.roundState.discardPile.add(discard)
            events.append(.playerDiscarded(playerIndex: currentPlayerIndex, card: discard))
            
            // Check for scat
            if Scoring.isScat(player: gameState.players[currentPlayerIndex]) {
                events.append(contentsOf: EventHandlers.handleScat(gameState: &gameState))
                events.append(contentsOf: GameFlow.endRound(gameState: &gameState))
                return events
            }
        }
        
        // Next player
        let newIndex = GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: currentPlayerIndex)
        gameState.roundState.currentPlayerIndex = newIndex

        // Check if knock round is over
        let knockRoundOver = gameState.roundState.knockingPlayerIndex == newIndex
        if  knockRoundOver {
            events.append(contentsOf: EventHandlers.handleKnockResolution(gameState: &gameState))
            events.append(contentsOf: GameFlow.endRound(gameState: &gameState))
            return events
        }
        
        return events
    }
}
