enum MoveRules {
    static func canKnock(gameState: GameState) -> Bool {
        !gameState.roundState.isKnocked
    }
    
    static func legalDiscards(for source: DrawSource, in gameState: GameState) -> [Card] {
        let currentPlayer = gameState.players[gameState.roundState.currentPlayerIndex]

        let drawnCard = switch source {
        case .drawPile:
            gameState.roundState.drawPile.topCard
        case .discardPile:
            gameState.roundState.discardPile.topCard
        }

        return currentPlayer.cards + [drawnCard]
    }
    
    static func validate(move: Move, in gameState: GameState) throws {
        guard gameState.isStarted else {
            throw ScatError.gameNotStarted
        }
        
        guard GameQueries.isActive(gameState: gameState) else {
            throw ScatError.gameOver
        }
        
        switch move {
        case .knock:
            guard canKnock(gameState: gameState) else {
                throw ScatError.alreadyKnocked
            }
            
        case let .drawAndDiscard(source, discard):
            guard legalDiscards(for: source, in: gameState).contains(discard) else {
                throw ScatError.invalidDiscard(card: discard)
            }
        }
    }
}
