public enum DrawSource: Equatable, Codable, CaseIterable {
    case drawPile
    case discardPile
}

extension DrawSource: CustomStringConvertible {
    public var description: String {
        switch self {
        case .drawPile:
            return "draw pile"
        case .discardPile:
            return "discard pile"
        }
    }
}
