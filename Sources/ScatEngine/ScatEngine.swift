import Foundation

public struct ScatEngine {
    var gameState: GameState
    
    public var topDiscard: Card {
        gameState.roundState.discardPile.topCard!
    }
    
    public var topDraw: Card {
        gameState.roundState.drawPile.topCard!
    }
    
    public var players: [Player] {
        gameState.players
    }
    
    public var activePlayers: [Player] {
        getActivePlayers(gameState: gameState)
    }
    
    public var currentPlayer: Player {
        gameState.players[gameState.roundState.currentTurnIndex]
    }
    
    public var isKnocked: Bool {
        gameState.roundState.isKnocked
    }
    
    public var knockingPlayer: Player? {
        guard let id = gameState.roundState.knockerID else { return nil }
        guard let player = getPlayer(id: id) else { fatalError("Knocker not found") }
        return player
    }
    
    public var isActive: Bool {
        isGameActive(gameState: gameState)
    }
    
    public var winner: Player? {
        getWinner(gameState: gameState)
    }
    
    public init(seed: UInt64, players: [String], startingChips: Int = 3) {
        precondition(players.count >= 2 && players.count <= 8, "Player count must be between 2 and 8, got \(players.count)")
        precondition(startingChips > 0, "Starting chips must be greater than 0")
        
        let playerObjs: [Player] = players.map { name in
            Player(name: name, chips: startingChips)
        }
        gameState = GameState(rng: SeededGenerator(seed), players: playerObjs)
        dealDeck(gameState: &gameState)
        
        if hasScat(gameState: gameState) {
            handleScat(gameState: &gameState)
        }
    }
    
    public func getPlayer(id: UUID) -> Player? {
        return gameState.players.first(where: { $0.id == id })
    }
    
    public mutating func apply(_ move: Move) throws {
        let currentPlayerIndex = gameState.roundState.currentTurnIndex
        let currentPlayer = gameState.players[currentPlayerIndex]
        
        guard isGameActive(gameState: gameState) else { throw ScatError.gameAlreadyOver }
        guard move.playerID == currentPlayer.id else { throw ScatError.notYourTurn }
        guard currentPlayer.isAlive else { throw ScatError.playerEliminated }
        
        guard !gameState.roundState.drawPile.isEmpty else {
            fatalError("Draw pile is empty, this should never happen")
        }
        guard !gameState.roundState.discardPile.isEmpty else {
            fatalError("Discard pile is empty, this should never happen")
        }

        switch move.action {
        case .knock:
            guard !gameState.roundState.isKnocked else { throw ScatError.playerKnockedDuringKnock }
            gameState.roundState.isKnocked = true
            gameState.roundState.knockerID = gameState.players[currentPlayerIndex].id
            
        case let .drawAndDiscard(source, discard):
            // Pickup card from source
            switch source {
            case .drawPile:
                gameState.players[currentPlayerIndex].addCard(gameState.roundState.drawPile.draw()!)
                
                // Reshufle if draw pile is empty
                if gameState.roundState.drawPile.isEmpty {
                    // takeAll() is okay because discardPile will be populated with the discard from move
                    gameState.roundState.drawPile.setCards(gameState.roundState.discardPile.takeAll())
                    gameState.roundState.drawPile.shuffle(using: &gameState.rng)
                }
            case .discardPile:
                gameState.players[currentPlayerIndex].addCard(gameState.roundState.discardPile.draw()!)
            }

            // Remove discarded card from hand
            guard gameState.players[currentPlayerIndex].hasCard(discard) else {
                throw ScatError.playerDiscardedCardTheyDontHave
            }
            gameState.players[currentPlayerIndex].removeCard(discard)
            
            // Place it on the discard pile
            gameState.roundState.discardPile.add(discard)
            
            // Check for scat
            if isScat(player: gameState.players[currentPlayerIndex]) {
                handleScat(gameState: &gameState)
                return
            }
        }
        
        let newIndex = findNextAlivePlayer(gameState: gameState, currentIndex: gameState.roundState.currentTurnIndex)
        gameState.roundState.currentTurnIndex = newIndex

        // Check if knock round is over
        let currentPlayerID = gameState.players[gameState.roundState.currentTurnIndex].id
        let knockRoundOver = gameState.roundState.isKnocked && currentPlayerID == gameState.roundState.knockerID
        if  knockRoundOver {
            resolveKnock(gameState: &gameState)
        }
    }
}
