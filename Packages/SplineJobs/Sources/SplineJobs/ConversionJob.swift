import Foundation
import SplineDomain

public enum ConversionJobState: String, Codable, Sendable {
    case queued
    case running
    case paused
    case completed
    case failed
    case canceled
}

public struct ConversionJob: Codable, Sendable, Equatable {
    public let id: UUID
    public let createdAt: Date
    public var updatedAt: Date
    public let inputURL: URL
    public let outputURL: URL
    public let intent: ConversionIntent
    public var state: ConversionJobState
    public var progress: Double
    public var failureMessage: String?

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        inputURL: URL,
        outputURL: URL,
        intent: ConversionIntent,
        state: ConversionJobState = .queued,
        progress: Double = 0,
        failureMessage: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.intent = intent
        self.state = state
        self.progress = progress
        self.failureMessage = failureMessage
    }
}
