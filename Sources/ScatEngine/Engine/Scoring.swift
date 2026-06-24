public func value(of card: Card) -> Int {
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

public func score(of player: Player) -> Int {
    let cards = player.cards
    return Suit.allCases.map { suit in
        cards.filter { $0.suit == suit }.map { value(of: $0) }.reduce(0, +)
    }.max() ?? 0
}

func isScat(player: Player) -> Bool {
    score(of: player) == 31
}

func hasScat(gameState: GameState) -> Bool {
    gameState.players.contains { isScat(player: $0) }
}
