import Foundation

public struct Move: Equatable, Codable {
    public let playerID: UUID
    public let action: Action

    public init(playerID: UUID, action: Action) {
        self.playerID = playerID
        self.action = action
    }
}
