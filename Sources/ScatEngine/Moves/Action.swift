public enum Action: Equatable, Codable {
    case drawAndDiscard(source: DrawSource, discard: Card)
    case knock
}
