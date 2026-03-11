import Foundation

public enum ConversionEngineError: Error, LocalizedError, Sendable, Equatable {
    case unsupportedFormat
    case invalidInput
    case fileReadFailed
    case fileWriteFailed
    case decodeFailed
    case encodeFailed

    public var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "The format is not supported by the current runtime."
        case .invalidInput:
            return "The input file could not be interpreted as a supported image document."
        case .fileReadFailed:
            return "The input file could not be read."
        case .fileWriteFailed:
            return "The output file could not be written."
        case .decodeFailed:
            return "The image decoder failed to decode the input."
        case .encodeFailed:
            return "The image encoder failed to encode the output."
        }
    }
}
