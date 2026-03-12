import Foundation
import SplineDomain

public enum ConversionOutcome: String, Codable, Sendable {
    case success
    case failure
}

public struct ConversionHistoryItem: Codable, Sendable, Equatable {
    public let id: UUID
    public let inputURL: URL
    public let outputURL: URL
    public let intent: ConversionIntent
    public let startedAt: Date
    public let finishedAt: Date
    public let outcome: ConversionOutcome
    public let message: String?

    public init(
        id: UUID = UUID(),
        inputURL: URL,
        outputURL: URL,
        intent: ConversionIntent,
        startedAt: Date,
        finishedAt: Date,
        outcome: ConversionOutcome,
        message: String?
    ) {
        self.id = id
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.intent = intent
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.outcome = outcome
        self.message = message
    }
}

public actor ConversionHistoryStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.outputFormatting = [.sortedKeys]
    }

    public func load() throws -> [ConversionHistoryItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([ConversionHistoryItem].self, from: data)
    }

    public func append(_ item: ConversionHistoryItem) throws {
        var current = try load()
        current.append(item)
        let data = try encoder.encode(current)
        try data.write(to: fileURL, options: .atomic)
    }
}
