import Foundation

public struct Move: Equatable, Codable {
    public let playerID: UUID
    public let action: Action
}
