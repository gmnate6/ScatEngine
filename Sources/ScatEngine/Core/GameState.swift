struct GameState: Codable {
    var rng: SeededGenerator
    var players: [Player]
    var startingPlayerIndex: Int
    var roundState: RoundState
    var hasStarted: Bool
    var moveCount: Int
    
    init(rng: SeededGenerator, players: [Player]) {
        precondition(!players.isEmpty, "Must have at least one player")
        
        self.rng = rng
        self.players = players
        self.startingPlayerIndex = 0
        self.roundState = RoundState(startingPlayerIndex: self.startingPlayerIndex)
        self.hasStarted = false
        self.moveCount = 0
    }
}
