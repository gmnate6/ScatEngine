enum ValidationError: Error {
    case invalidPlayerCount
    case invalidDeck
    case emptyDrawPile
    case emptyDiscardPile
    case deadCurrentPlayer
    case deadKnockingPlayer
    case invalidHandSize
}

extension ValidationError {
    public var description: String {
        switch self {
        case .invalidPlayerCount:
            return "Invalid player count"
        case .invalidDeck:
            return "Deck integrity violated"
        case .emptyDrawPile:
            return "Draw pile is empty"
        case .emptyDiscardPile:
            return "Discard pile is empty"
        case .deadCurrentPlayer:
            return "Current player is dead"
        case .deadKnockingPlayer:
            return "Knocking player is dead"
        case .invalidHandSize:
            return "Player has an invalid hand size"
        }
    }
}
