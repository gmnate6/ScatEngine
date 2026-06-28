public enum Scoring {
    public static func value(of card: Card) -> Int {
        switch card.rank {
        case .two:   return 2
        case .three: return 3
        case .four:  return 4
        case .five:  return 5
        case .six:   return 6
        case .seven: return 7
        case .eight: return 8
        case .nine:  return 9
        case .ten, .jack, .queen, .king: return 10
        case .ace:   return 11
        }
    }

    public static func score(of player: Player) -> Int {
        guard player.isAlive else { return 0 }
        
        let cards = player.cards
        precondition(cards.count == 3, "A player must have 3 cards")
        
        return Suit.allCases.map { suit in
            cards.filter { $0.suit == suit }.map { value(of: $0) }.reduce(0, +)
        }.max() ?? 0
    }

    public static func isScat(player: Player) -> Bool {
        guard player.isAlive else { return false }
        return score(of: player) == 31
    }
}
