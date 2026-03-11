import Foundation

public struct ConversionIntent: Codable, Sendable, Equatable {
    public let sourceFormat: ImageFormat
    public let targetFormat: ImageFormat
    public let containsAlphaChannel: Bool
    public let containsAnimation: Bool
    public let options: ConversionOptions

    public init(
        sourceFormat: ImageFormat,
        targetFormat: ImageFormat,
        containsAlphaChannel: Bool,
        containsAnimation: Bool,
        options: ConversionOptions
    ) {
        self.sourceFormat = sourceFormat
        self.targetFormat = targetFormat
        self.containsAlphaChannel = containsAlphaChannel
        self.containsAnimation = containsAnimation
        self.options = options
    }
}
