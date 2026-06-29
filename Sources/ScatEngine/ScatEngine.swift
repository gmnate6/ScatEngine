import Foundation
import CryptoKit

private struct SaveFile: Codable {
    let version: Int
    let state: GameState
}

public class ScatEngine {
    private static let saveVersion = 1
    private var gameState: GameState
    
    public var topOfDiscardPile: Card {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.discardPile.topCard
    }
    
    public var topOfDrawPile: Card {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.drawPile.topCard
    }
    
    public var drawPileSize: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.drawPile.count
    }
    
    public var discardPileSize: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.discardPile.count
    }
    
    public var players: [Player] {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.players
    }
    
    public var alivePlayers: [Player] {
        precondition(gameState.isStarted, "Must call startGame() first")
        return GameQueries.alivePlayerIndices(in: gameState).map { gameState.players[$0] }
    }
    
    public var currentPlayerIndex: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.currentPlayerIndex
    }
    
    public var currentPlayer: Player {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.players[gameState.roundState.currentPlayerIndex]
    }
    
    public var currentPlayerHand: [Card] {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.players[gameState.roundState.currentPlayerIndex].cards
    }
    
    public var canKnock: Bool {
        precondition(gameState.isStarted, "Must call startGame() first")
        return !gameState.roundState.isKnocked
    }
    
    public var isKnocked: Bool {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.roundState.isKnocked
    }
    
    public var knockingPlayerIndex: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        precondition(gameState.roundState.isKnocked)
        return gameState.roundState.knockingPlayerIndex!
    }
    
    public var winnerIndex: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        precondition(!GameQueries.isActive(gameState: gameState))
        return GameQueries.winnerIndex(gameState: gameState)
    }
    
    public var winner: Player {
        precondition(gameState.isStarted, "Must call startGame() first")
        precondition(!GameQueries.isActive(gameState: gameState))
        return gameState.players[GameQueries.winnerIndex(gameState: gameState)]
    }
    
    public var isStarted: Bool {
        return gameState.isStarted
    }
    
    public var isActive: Bool {
        guard gameState.isStarted else { return false }
        return GameQueries.isActive(gameState: gameState)
    }
    
    public var moveCount: Int {
        precondition(gameState.isStarted, "Must call startGame() first")
        return gameState.moveCount
    }

    public init(seed: UInt64, players: [String], startingChips: Int = 3) {
        precondition(players.count >= 2 && players.count <= 8, "Player count must be between 2 and 8, got \(players.count)")
        precondition(startingChips > 0, "Starting chips must be greater than 0")
        
        let playerObjs: [Player] = players.map { name in
            Player(name: name, chips: startingChips)
        }
        
        gameState = GameState(rng: SeededGenerator(seed: seed), players: playerObjs)
    }
    
    public init(data: Data) throws {
        let file = try JSONDecoder().decode(SaveFile.self, from: data)

        switch file.version {
        case 1:
            self.gameState = file.state

        default:
            throw ScatError.unsupportedSaveVersion(version: file.version)
        }

        try validate(gameState: gameState)
    }
    
    public func encode() throws -> Data {
        let file = SaveFile(
            version: Self.saveVersion,
            state: gameState
        )

        return try JSONEncoder().encode(file)
    }
    
    public func stateHash() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        let data = try encoder.encode(gameState)
        
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    public func startGame() -> [GameEvent] {
        precondition(!gameState.isStarted, "Must call startGame() first")
        gameState.isStarted = true
        
        var events: [GameEvent] = []
        
        events.append(.gameStarted)
        events += startRound(gameState: &gameState)
        return events
    }
    
    public func makeMove(_ move: Move) throws -> [GameEvent] {
        guard gameState.isStarted else { throw ScatError.gameNotStarted }
        guard GameQueries.isActive(gameState: gameState) else { throw ScatError.gameOver }

        let currentPlayerIndex = gameState.roundState.currentPlayerIndex
        
        defer {
            assertValidState(gameState: gameState, context: "after makeMove(\(move))")
        }
        
        var events: [GameEvent] = []
        
        switch move {
        case .knock:
            guard !gameState.roundState.isKnocked else {
                throw ScatError.alreadyKnocked
            }
            gameState.roundState.knockingPlayerIndex = currentPlayerIndex
            events.append(.playerKnocked(playerIndex: currentPlayerIndex))
            
        case let .drawAndDiscard(source, discard):
            // Draw Card
            let card: Card = switch source {
            case .drawPile:   gameState.roundState.drawPile.draw()
            case .discardPile: gameState.roundState.discardPile.draw()
            }
            
            // Add to player
            gameState.players[currentPlayerIndex].addCard(card)
            events.append(.playerDrew(playerIndex: currentPlayerIndex, card: card, source: source))
            
            // Reshuffle
            if gameState.roundState.drawPile.isEmpty {
                gameState.roundState.drawPile = Pile(cards: gameState.roundState.discardPile.takeAll())
                gameState.roundState.drawPile.shuffle(using: &gameState.rng)
                events.append(.drawPileReshuffled)
            }

            // Discard
            try gameState.players[currentPlayerIndex].removeCard(discard)
            gameState.roundState.discardPile.add(discard)
            events.append(.playerDiscarded(playerIndex: currentPlayerIndex, card: discard))
            
            // Check for scat
            if Scoring.isScat(player: gameState.players[currentPlayerIndex]) {
                events.append(contentsOf: handleScat(gameState: &gameState))
                events.append(contentsOf:endRound(gameState: &gameState))
                return events
            }
        }
        
        // Next player
        let newIndex = GameQueries.nextAlivePlayerIndex(gameState: gameState, currentIndex: currentPlayerIndex)
        gameState.roundState.currentPlayerIndex = newIndex

        // Check if knock round is over
        let knockRoundOver = gameState.roundState.knockingPlayerIndex == newIndex
        if  knockRoundOver {
            events.append(contentsOf: handleKnockResolution(gameState: &gameState))
            events.append(contentsOf:endRound(gameState: &gameState))
            return events
        }
        
        return events
    }
}
