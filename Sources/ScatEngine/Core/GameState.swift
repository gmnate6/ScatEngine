struct GameState {
    var rng: SeededGenerator
    var players: [Player]
    var startingPlayerIndex: Int
    var roundState: RoundState
    
    init(rng: SeededGenerator, players: [Player]) {
        self.rng = rng
        self.players = players
        self.startingPlayerIndex = 0
        self.roundState = RoundState(startingPlayerIndex: self.startingPlayerIndex)
    }
}
