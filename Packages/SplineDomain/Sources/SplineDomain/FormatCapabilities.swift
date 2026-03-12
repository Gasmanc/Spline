import Foundation

public struct FormatCapabilities: Sendable, Equatable {
    public let supportsAlpha: Bool
    public let supportsAnimation: Bool
    public let supportsVectorPrimitives: Bool
    public let supportsEmbeddedICCProfile: Bool
    public let supportsCMYKEncoding: Bool

    public init(
        supportsAlpha: Bool,
        supportsAnimation: Bool,
        supportsVectorPrimitives: Bool,
        supportsEmbeddedICCProfile: Bool,
        supportsCMYKEncoding: Bool
    ) {
        self.supportsAlpha = supportsAlpha
        self.supportsAnimation = supportsAnimation
        self.supportsVectorPrimitives = supportsVectorPrimitives
        self.supportsEmbeddedICCProfile = supportsEmbeddedICCProfile
        self.supportsCMYKEncoding = supportsCMYKEncoding
    }
}

public enum FormatCapabilityRegistry {
    private static let values: [ImageFormat: FormatCapabilities] = [
        .jpeg: .init(
            supportsAlpha: false,
            supportsAnimation: false,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: true
        ),
        .bmp: .init(
            supportsAlpha: true,
            supportsAnimation: false,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: false,
            supportsCMYKEncoding: false
        ),
        .heic: .init(
            supportsAlpha: true,
            supportsAnimation: true,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: false
        ),
        .webp: .init(
            supportsAlpha: true,
            supportsAnimation: true,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: false
        ),
        .gif: .init(
            supportsAlpha: true,
            supportsAnimation: true,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: false,
            supportsCMYKEncoding: false
        ),
        .raw: .init(
            supportsAlpha: false,
            supportsAnimation: false,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: false
        ),
        .svg: .init(
            supportsAlpha: true,
            supportsAnimation: true,
            supportsVectorPrimitives: true,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: false
        ),
        .tiff: .init(
            supportsAlpha: true,
            supportsAnimation: false,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: true
        ),
        .png: .init(
            supportsAlpha: true,
            supportsAnimation: false,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: false
        ),
        .avif: .init(
            supportsAlpha: true,
            supportsAnimation: true,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: false
        ),
        .hdr: .init(
            supportsAlpha: false,
            supportsAnimation: false,
            supportsVectorPrimitives: false,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: false
        ),
        .eps: .init(
            supportsAlpha: true,
            supportsAnimation: false,
            supportsVectorPrimitives: true,
            supportsEmbeddedICCProfile: false,
            supportsCMYKEncoding: true
        ),
        .pdf: .init(
            supportsAlpha: true,
            supportsAnimation: false,
            supportsVectorPrimitives: true,
            supportsEmbeddedICCProfile: true,
            supportsCMYKEncoding: true
        )
    ]

    public static func capabilities(for format: ImageFormat) -> FormatCapabilities {
        guard let value = values[format] else {
            preconditionFailure("Capabilities missing for format: \(format)")
        }
        return value
    }
}
