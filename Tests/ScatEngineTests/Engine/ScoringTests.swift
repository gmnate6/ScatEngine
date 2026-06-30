import Testing
@testable import ScatEngine

struct ScoringTest {
    @Test
    func valueOfCardTest() {
        #expect(Scoring.value(of: .init(rank: .queen, suit: .spades)) == 10)
        #expect(Scoring.value(of: .init(rank: .two, suit: .hearts))   == 2)
        #expect(Scoring.value(of: .init(rank: .ace, suit: .diamonds)) == 11)
    }
    
    @Test
    func scoreOfPlayerTest() {
        var p1 = Player(chips: 3)
        p1.addCard(Card(rank: .two, suit: .clubs))
        p1.addCard(Card(rank: .ace, suit: .clubs))
        p1.addCard(Card(rank: .jack, suit: .clubs))
        #expect(Scoring.score(of: p1) == 23)
        
        var p2 = Player(chips: 3)
        p2.addCard(Card(rank: .two, suit: .clubs))
        p2.addCard(Card(rank: .ace, suit: .hearts))
        p2.addCard(Card(rank: .jack, suit: .diamonds))
        #expect(Scoring.score(of: p2) == 11)
        
        var p3 = Player(chips: 3)
        p3.addCard(Card(rank: .two, suit: .clubs))
        p3.addCard(Card(rank: .three, suit: .clubs))
        p3.addCard(Card(rank: .jack, suit: .diamonds))
        #expect(Scoring.score(of: p3) == 10)
        
        var p4 = Player(chips: 3)
        p4.addCard(Card(rank: .two, suit: .clubs))
        p4.addCard(Card(rank: .two, suit: .spades))
        p4.addCard(Card(rank: .two, suit: .diamonds))
        #expect(Scoring.score(of: p4) == 2)
        
        var p5 = Player(chips: 3)
        p5.addCard(Card(rank: .ace, suit: .spades))
        p5.addCard(Card(rank: .king, suit: .spades))
        p5.addCard(Card(rank: .queen, suit: .spades))
        #expect(Scoring.score(of: p5) == 31)
    }
    
    @Test
    func isScatTest() {
        var p1 = Player(chips: 3)
        p1.addCard(Card(rank: .ace, suit: .clubs))
        p1.addCard(Card(rank: .king, suit: .clubs))
        p1.addCard(Card(rank: .queen, suit: .clubs))
        #expect(Scoring.isScat(player: p1))
        
        var p2 = Player(chips: 3)
        p2.addCard(Card(rank: .ace, suit: .clubs))
        p2.addCard(Card(rank: .king, suit: .diamonds))
        p2.addCard(Card(rank: .queen, suit: .hearts))
        #expect(!Scoring.isScat(player: p2))
        
        var p3 = Player(chips: 3)
        p3.addCard(Card(rank: .two, suit: .diamonds))
        p3.addCard(Card(rank: .three, suit: .diamonds))
        p3.addCard(Card(rank: .four, suit: .diamonds))
        #expect(!Scoring.isScat(player: p3))
        
        var p4 = Player(chips: 3)
        p4.addCard(Card(rank: .four, suit: .clubs))
        p4.addCard(Card(rank: .four, suit: .diamonds))
        p4.addCard(Card(rank: .four, suit: .hearts))
        #expect(!Scoring.isScat(player: p4))
    }
}
