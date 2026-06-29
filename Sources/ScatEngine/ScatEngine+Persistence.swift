import Foundation
import CryptoKit

public extension ScatEngine {
    static let currentSaveVersion = 1

    struct SaveFile: Codable {
        let version: Int
        let state: GameState
    }

    private static let deterministicEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64

        return encoder
    }()

    private static let deterministicDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    convenience init(data: Data) throws {
        let file = try Self.deterministicDecoder.decode(SaveFile.self, from: data)

        guard file.version == Self.currentSaveVersion else {
            throw ScatError.unsupportedSaveVersion(version: file.version)
        }

        self.init(gameState: file.state)

        try validate(gameState: gameState)
    }

    func makeSaveData() throws -> Data {
        let file = SaveFile(
            version: Self.currentSaveVersion,
            state: gameState
        )

        return try Self.deterministicEncoder.encode(file)
    }

    func stateHash() -> String {
        guard let data = try? Self.deterministicEncoder.encode(gameState) else {
            preconditionFailure("GameState is not encodable — engine invariant violated")
        }

        let digest = SHA256.hash(data: data)

        return digest.reduce(into: "") { result, byte in
            result += String(format: "%02x", byte)
        }
    }
}

private extension ScatEngine {
    convenience init(gameState: GameState) {
        self.init(seed: 0, players: ["temp1", "temp2"]) // dummy values, will be overwritten
        self.gameState = gameState
    }
}
