struct GameState: Codable {
    var rng: SeededGenerator
    var players: [Player]
    var startingPlayerIndex: Int
    var roundState: RoundState
    var isStarted: Bool
    var moveCount: Int
    
    init(rng: SeededGenerator, players: [Player]) {
        self.rng = rng
        self.players = players
        self.startingPlayerIndex = 0
        self.roundState = RoundState(startingPlayerIndex: self.startingPlayerIndex)
        self.isStarted = false
        self.moveCount = 0
    }
}
