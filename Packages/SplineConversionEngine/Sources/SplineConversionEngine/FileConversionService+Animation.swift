import Foundation
import SplineDomain

extension FileConversionService {
    func convertAnimated(
        _ animated: AnimatedRasterImage,
        inputURL: URL,
        outputURL: URL,
        intent: ConversionIntent
    ) throws {
        switch intent.options.animationPolicy {
        case .firstFrameOnly:
            try encodeFirstFrame(animated, outputURL: outputURL, intent: intent)
        case .preserveWhenSupported:
            if try preserveAnimationIfSupported(animated, inputURL: inputURL, outputURL: outputURL, intent: intent) {
                return
            }
            try encodeFirstFrame(animated, outputURL: outputURL, intent: intent)
        case .splitToFrames:
            try encodeFirstFrame(animated, outputURL: outputURL, intent: intent)
            try writeSplitFrames(animated, outputURL: outputURL, intent: intent)
        }
    }

    private func preserveAnimationIfSupported(
        _ animated: AnimatedRasterImage,
        inputURL: URL,
        outputURL: URL,
        intent: ConversionIntent
    ) throws -> Bool {
        let targetCapabilities = FormatCapabilityRegistry.capabilities(for: intent.targetFormat)
        guard targetCapabilities.supportsAnimation else {
            return false
        }

        if intent.sourceFormat == intent.targetFormat {
            try copyInputToOutput(inputURL: inputURL, outputURL: outputURL)
            return true
        }

        if intent.targetFormat == .gif {
            let normalizedFrames = try animated.frames.map { frame in
                AnimationFrame(
                    image: try normalizeColorIfNeeded(frame.image, intent: intent),
                    duration: frame.duration
                )
            }

            let normalizedAnimation = AnimatedRasterImage(frames: normalizedFrames, loopCount: animated.loopCount)
            try codecs.encodeAnimatedRasterImage(
                normalizedAnimation,
                to: outputURL,
                as: .gif,
                options: rasterEncodingOptions(intent: intent)
            )
            return true
        }

        return false
    }

    private func encodeFirstFrame(
        _ animated: AnimatedRasterImage,
        outputURL: URL,
        intent: ConversionIntent
    ) throws {
        guard let firstFrame = animated.frames.first else {
            throw ConversionEngineError.decodeFailed
        }

        let normalizedImage = try normalizeColorIfNeeded(firstFrame.image, intent: intent)
        try encodeRasterImage(normalizedImage, outputURL: outputURL, format: intent.targetFormat, intent: intent)
    }

    private func writeSplitFrames(
        _ animated: AnimatedRasterImage,
        outputURL: URL,
        intent: ConversionIntent
    ) throws {
        let baseName = outputURL.deletingPathExtension().lastPathComponent
        let outputDirectory = outputURL.deletingLastPathComponent()
        let fileExtension = outputURL.pathExtension
        var entries: [SplitFrameEntry] = []

        for (index, frame) in animated.frames.enumerated() {
            let frameName = splitFrameName(baseName: baseName, index: index + 1, fileExtension: fileExtension)
            let frameURL = outputDirectory.appendingPathComponent(frameName)
            let normalizedImage = try normalizeColorIfNeeded(frame.image, intent: intent)
            try encodeRasterImage(normalizedImage, outputURL: frameURL, format: intent.targetFormat, intent: intent)
            entries.append(SplitFrameEntry(fileName: frameName, duration: frame.duration))
        }

        let manifest = SplitFrameManifest(frames: entries)
        let manifestURL = outputDirectory.appendingPathComponent("\(baseName)-frames.json")
        let data = try JSONEncoder().encode(manifest)
        try data.write(to: manifestURL, options: .atomic)
    }

    private func splitFrameName(baseName: String, index: Int, fileExtension: String) -> String {
        "\(baseName)-frame-\(String(format: "%04d", index)).\(fileExtension)"
    }
}

private struct SplitFrameEntry: Codable {
    let fileName: String
    let duration: Double
}

private struct SplitFrameManifest: Codable {
    let frames: [SplitFrameEntry]
}
