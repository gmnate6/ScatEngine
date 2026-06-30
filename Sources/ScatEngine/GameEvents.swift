public enum GameEvent: Codable, Equatable {
    // Setup
    case gameStarted
    case roundStarted
    case cardsDealt
    // Turn actions
    case playerKnocked(playerIndex: Int)
    case playerDrew(playerIndex: Int, card: Card, source: DrawSource)
    case drawPileReshuffled
    case playerDiscarded(playerIndex: Int, card: Card)
   
    // Round resolution
    case scat(scatters: [Int], losers: [Int], onDeal: Bool)
    case knockResolved(knockerIndex: Int, results: KnockResults)
    case playersEliminated(playerIndices: [Int])
   
    // Lifecycle
    case roundEnded
    case gameEnded(winnerIndex: Int)
   
    public enum KnockResults: Codable, Equatable {
        case knockerLost
        case knockerWon(losers: [Int])
    }
}

extension GameEvent: CustomStringConvertible {
    public var description: String {
        switch self {
        case .gameStarted:
            return "Game started"
        case .roundStarted:
            return "Round started"
        case .cardsDealt:
            return "Cards dealt"
        case let .playerKnocked(playerIndex):
            return "Player \(playerIndex) knocked"
        case let .playerDrew(playerIndex, card, source):
            return "Player \(playerIndex) drew \(card) from \(source)"
        case .drawPileReshuffled:
            return "Draw pile reshuffled"
        case let .playerDiscarded(playerIndex, card):
            return "Player \(playerIndex) discarded \(card)"
        case let .scat(scatters, losers, onDeal):
            return "Scat! Scatters: \(scatters), Losers: \(losers), onDeal: \(onDeal)"
        case let .knockResolved(knockerIndex, results):
            return "Knock resolved by player \(knockerIndex): \(results)"
        case let .playersEliminated(indices):
            return "Players eliminated: \(indices)"
        case .roundEnded:
            return "Round ended"
        case let .gameEnded(winnerIndex):
            return "Game ended. Winner: \(winnerIndex)"
        }
    }
}

extension GameEvent.KnockResults: CustomStringConvertible {
    public var description: String {
        switch self {
        case .knockerLost:
            return "Knocker lost"
        case let .knockerWon(losers):
            return "Knocker won. Losers: \(losers)"
        }
    }
}
