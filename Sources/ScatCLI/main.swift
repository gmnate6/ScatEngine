import ScatEngine

var engine = ScatEngine(seed: 42, players: ["Alice", "Bob", "Charlie"])

print("Game started!")

print("    Discard:")
let card: Card = engine.topDiscard
print("\(card.rank) of \(card.suit)")

for player: Player in engine.players {
    print("\n    \(player.name):")
    for card: Card in player.cards {
        print("\(card.rank) of \(card.suit)")
    }
    print("\(player.chips) chips")
}
