public enum Move: Equatable, Codable {
    case drawAndDiscard(source: DrawSource, discard: Card)
    case knock
}

extension Move: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .drawAndDiscard(source, discard):
            return "Drew from \(source) and discarded \(discard)"
        case .knock:
            return "Knocked"
        }
    }
}
