import Testing
@testable import ScatEngine

struct PlayerTests {
    @Test
    func playerStartsWithExpectedValues() {
        let player = Player(name: "Nathan", chips: 100)

        #expect(player.name == "Nathan")
        #expect(player.chips == 100)
        #expect(player.cards.isEmpty)
        #expect(player.isAlive)
    }
    
    @Test
    func playerIsEliminatedAtZeroChips() {
        let player = Player(name: "Nathan", chips: 0)

        #expect(!player.isAlive)
    }
    
    @Test
    func chipsCannotGoNegative() {
        var player = Player(name: "Nathan", chips: 100)

        player.chips = -50

        #expect(player.chips == 0)
        #expect(!player.isAlive)
    }
    
    @Test
    func addCardAddsCardToHand() {
        var player = Player(name: "Nathan", chips: 100)

        let card = Card(rank: Rank.ace, suit: Suit.spades)

        player.addCard(card)

        #expect(player.cards.count == 1)
        #expect(player.hasCard(card))
    }
    
    @Test
    func removeCardRemovesCardFromHand() throws {
        var player = Player(name: "Nathan", chips: 100)

        let card = Card(rank: Rank.ace, suit: Suit.spades)

        player.addCard(card)
        player.removeCard(card)

        #expect(!player.hasCard(card))
        #expect(player.cards.isEmpty)
    }
    
    @Test
    func removeCardsClearsHand() {
        var player = Player(name: "Nathan", chips: 100)

        player.addCard(Card(rank: .ace, suit: .spades))
        player.addCard(Card(rank: .king, suit: .hearts))

        player.removeCards()

        #expect(player.cards.isEmpty)
    }
}
