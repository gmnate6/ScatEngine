enum ValidationError: Error {
    case invalidDeck
    case emptyDrawPile
    case emptyDiscardPile
    case invalidPlayerCount
    case deadCurrentPlayer
    case deadKnockingPlayer
}

extension ValidationError {
    public var description: String {
        switch self {
        case .invalidDeck:
            return "Deck integrity violated"
        case .emptyDrawPile:
            return "Draw pile is empty"
        case .emptyDiscardPile:
            return "Discard pile is empty"
        case .invalidPlayerCount:
            return "Invalid player count"
        case .deadCurrentPlayer:
            return "Current player is dead"
        case .deadKnockingPlayer:
            return "Knocking player is dead"
        }
    }
}

