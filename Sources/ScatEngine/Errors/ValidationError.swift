enum ValidationError: Error {
    case invalidPlayerCount
    case invalidDeck
    case emptyDrawPile
    case emptyDiscardPile
    case invalidHandSize
    case deadCurrentPlayer
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
        case .invalidHandSize:
            return "Player has an invalid hand size"
        case .deadCurrentPlayer:
            return "Current player is dead"
        }
    }
}
