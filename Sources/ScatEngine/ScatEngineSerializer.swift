import Foundation
import CryptoKit

public enum ScatEngineSerializer {
    static let currentVersion = 1
    
    struct SaveFile: Codable {
        let version: Int
        let state: Data
    }
    
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        return encoder
    }()
    
    static let stateEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        JSONDecoder()
    }()
    
    public static func encode(_ engine: ScatEngine) throws -> Data {
        let stateData = try stateEncoder.encode(engine.gameState)
        
        let file = SaveFile(
            version: currentVersion,
            state: stateData
        )
        
        return try encoder.encode(file)
    }
    
    public static func decode(_ data: Data) throws -> ScatEngine {
        let file = try decoder.decode(SaveFile.self, from: data)
        
        guard file.version == currentVersion else {
            throw ScatError.unsupportedSaveVersion(version: file.version)
        }
        
        let state = try decoder.decode(GameState.self, from: file.state)
        
        return try ScatEngine(gameState: state)
    }
    
    public static func hash(_ engine: ScatEngine) -> String {
        let data: Data
        do {
            data = try encode(engine)
        } catch {
            preconditionFailure("ScatEngine invariant violated: failed to encode GameState for hashing. Error: \(error)")
        }
        
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
