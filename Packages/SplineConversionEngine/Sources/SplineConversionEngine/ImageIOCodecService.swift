import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import SplineDomain

public struct DecodedRasterImage: Sendable {
    public let cgImage: CGImage

    public init(cgImage: CGImage) {
        self.cgImage = cgImage
    }
}

public struct AnimationFrame: Sendable {
    public let image: DecodedRasterImage
    public let duration: Double

    public init(image: DecodedRasterImage, duration: Double) {
        self.image = image
        self.duration = duration
    }
}

public struct AnimatedRasterImage: Sendable {
    public let frames: [AnimationFrame]
    public let loopCount: Int

    public init(frames: [AnimationFrame], loopCount: Int) {
        self.frames = frames
        self.loopCount = loopCount
    }
}

public struct RasterEncodingOptions: Sendable {
    public let metadataPolicy: MetadataPolicy
    public let preserveICCProfile: Bool
    public let frameDuration: Double?

    public init(
        metadataPolicy: MetadataPolicy,
        preserveICCProfile: Bool,
        frameDuration: Double? = nil
    ) {
        self.metadataPolicy = metadataPolicy
        self.preserveICCProfile = preserveICCProfile
        self.frameDuration = frameDuration
    }
}

public struct ImageIOCodecService: Sendable {
    private static let destinationTypeMap: [ImageFormat: String] = [
        .jpeg: UTType.jpeg.identifier,
        .bmp: UTType.bmp.identifier,
        .heic: UTType.heic.identifier,
        .gif: UTType.gif.identifier,
        .tiff: UTType.tiff.identifier,
        .png: UTType.png.identifier
    ]

    public init() {}

    public func decodeRasterImage(at inputURL: URL, as format: ImageFormat) throws -> DecodedRasterImage {
        guard !format.isVector else {
            throw ConversionEngineError.unsupportedFormat
        }

        if format == .webp {
            let data = try Data(contentsOf: inputURL)
            return try ExternalCodecBridge.decodeWebP(data: data)
        }

        if format == .avif {
            let data = try Data(contentsOf: inputURL)
            return try ExternalCodecBridge.decodeAVIF(data: data)
        }

        guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil) else {
            throw ConversionEngineError.fileReadFailed
        }

        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ConversionEngineError.decodeFailed
        }

        return DecodedRasterImage(cgImage: image)
    }

    public func decodeAnimatedRasterIfPresent(at inputURL: URL, as format: ImageFormat) throws -> AnimatedRasterImage? {
        guard !format.isVector else {
            throw ConversionEngineError.unsupportedFormat
        }

        if format == .webp || format == .avif {
            return nil
        }

        guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil) else {
            throw ConversionEngineError.fileReadFailed
        }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 1 else {
            return nil
        }

        var frames: [AnimationFrame] = []
        for index in 0..<frameCount {
            guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                throw ConversionEngineError.decodeFailed
            }

            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
            let duration = frameDuration(from: properties)
            frames.append(AnimationFrame(image: DecodedRasterImage(cgImage: image), duration: duration))
        }

        let sourceProperties = CGImageSourceCopyProperties(source, nil) as? [CFString: Any]
        let loopCount = gifLoopCount(from: sourceProperties)

        return AnimatedRasterImage(frames: frames, loopCount: loopCount)
    }

    public func encodeRasterImage(
        _ image: DecodedRasterImage,
        to outputURL: URL,
        as format: ImageFormat,
        options: RasterEncodingOptions = RasterEncodingOptions(metadataPolicy: .strip, preserveICCProfile: true)
    ) throws {
        if format == .webp {
            let encoded = try ExternalCodecBridge.encodeWebP(image: image)
            try encoded.write(to: outputURL, options: .atomic)
            return
        }

        if format == .avif {
            let encoded = try ExternalCodecBridge.encodeAVIF(image: image)
            try encoded.write(to: outputURL, options: .atomic)
            return
        }

        guard let destinationType = Self.destinationTypeMap[format] else {
            throw ConversionEngineError.unsupportedFormat
        }

        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            destinationType as CFString,
            1,
            nil
        ) else {
            throw ConversionEngineError.fileWriteFailed
        }

        CGImageDestinationAddImage(destination, image.cgImage, imageProperties(for: format, options: options))

        guard CGImageDestinationFinalize(destination) else {
            throw ConversionEngineError.encodeFailed
        }
    }

    public func encodeAnimatedRasterImage(
        _ image: AnimatedRasterImage,
        to outputURL: URL,
        as format: ImageFormat,
        options: RasterEncodingOptions
    ) throws {
        guard format == .gif,
              let destinationType = Self.destinationTypeMap[format] else {
            throw ConversionEngineError.unsupportedFormat
        }

        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            destinationType as CFString,
            image.frames.count,
            nil
        ) else {
            throw ConversionEngineError.fileWriteFailed
        }

        let destinationProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: image.loopCount
            ]
        ]
        CGImageDestinationSetProperties(destination, destinationProperties as CFDictionary)

        for frame in image.frames {
            let frameOptions = RasterEncodingOptions(
                metadataPolicy: options.metadataPolicy,
                preserveICCProfile: options.preserveICCProfile,
                frameDuration: frame.duration
            )
            CGImageDestinationAddImage(
                destination,
                frame.image.cgImage,
                imageProperties(for: format, options: frameOptions)
            )
        }

        guard CGImageDestinationFinalize(destination) else {
            throw ConversionEngineError.encodeFailed
        }
    }

    private func imageProperties(for format: ImageFormat, options: RasterEncodingOptions) -> CFDictionary? {
        var properties: [CFString: Any] = [:]

        _ = options.preserveICCProfile

        if format == .gif, let frameDuration = options.frameDuration {
            properties[kCGImagePropertyGIFDictionary] = [
                kCGImagePropertyGIFDelayTime: frameDuration
            ]
        }

        if options.metadataPolicy == .strip {
            properties[kCGImageDestinationMetadata] = kCFNull
        }

        guard !properties.isEmpty else {
            return nil
        }

        return properties as CFDictionary
    }

    private func frameDuration(from properties: [CFString: Any]?) -> Double {
        guard let gifProperties = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0.1
        }

        if let unclamped = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double,
           unclamped > 0 {
            return unclamped
        }

        if let clamped = gifProperties[kCGImagePropertyGIFDelayTime] as? Double,
           clamped > 0 {
            return clamped
        }

        return 0.1
    }

    private func gifLoopCount(from properties: [CFString: Any]?) -> Int {
        guard let gifProperties = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0
        }

        return gifProperties[kCGImagePropertyGIFLoopCount] as? Int ?? 0
    }
}
