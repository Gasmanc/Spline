import Foundation

public enum SVGTraceError: Error, LocalizedError, Sendable, Equatable {
    case readFailed
    case decodeFailed
    case unsupportedInput
    case writeFailed

    public var errorDescription: String? {
        switch self {
        case .readFailed:
            return "Input data could not be read."
        case .decodeFailed:
            return "Input could not be decoded to a raster image."
        case .unsupportedInput:
            return "This input format is currently unsupported by the SVG conversion path."
        case .writeFailed:
            return "SVG output could not be written."
        }
    }
}
