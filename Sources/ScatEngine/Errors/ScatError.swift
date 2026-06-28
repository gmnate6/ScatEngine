public enum ScatError: Error, Equatable, CustomStringConvertible {
    case gameNotStarted
    case gameOver
    case alreadyKnocked
    case cardNotInHand(card: Card)
    case unsupportedSaveVersion(version: Int)
}

extension ScatError {
    public var description: String {
        switch self {
        case .gameNotStarted:
            return "Game has not yet started"
        case .gameOver:
            return "Game is already over"
        case .alreadyKnocked:
            return "A player has already knocked this round"
        case .cardNotInHand(let card):
            return "Player does not hold the card: \(card)"
        case .unsupportedSaveVersion(let version):
            return "Unsupported save version: \(version)"
        }
    }
}
