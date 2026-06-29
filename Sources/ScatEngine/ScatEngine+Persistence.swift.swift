import Foundation
import CryptoKit

public extension ScatEngine {
    
    struct SaveFile: Codable {
        let version: Int
        let state: GameState
    }
    
    static let currentSaveVersion = 1
    
    convenience init(data: Data) throws {
        let file = try JSONDecoder().decode(SaveFile.self, from: data)
        
        switch file.version {
        case Self.currentSaveVersion:
            self.init(gameState: file.state)
        default:
            throw ScatError.unsupportedSaveVersion(version: file.version)
        }
        
        try validate(gameState: gameState)
    }
    
    func encode() throws -> Data {
        let file = SaveFile(
            version: Self.currentSaveVersion,
            state: gameState
        )
        return try JSONEncoder().encode(file)
    }
    
    func stateHash() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        let data = try encoder.encode(gameState)
        
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

private extension ScatEngine {
    convenience init(gameState: GameState) {
        self.init(seed: 0, players: []) // dummy values, will be overwritten
        self.gameState = gameState
    }
}
