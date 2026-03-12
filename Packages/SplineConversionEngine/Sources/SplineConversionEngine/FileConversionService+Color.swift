import CoreGraphics
import Foundation
import SplineDomain

extension FileConversionService {
    func normalizeColorIfNeeded(
        _ image: DecodedRasterImage,
        intent: ConversionIntent
    ) throws -> DecodedRasterImage {
        guard !intent.targetFormat.isVector else {
            return image
        }

        let targetColorSpace = resolvedOutputColorSpace(for: intent)

        if let existing = image.cgImage.colorSpace,
           existing.name == targetColorSpace.name {
            return image
        }

        let width = image.cgImage.width
        let height = image.cgImage.height
        let isCMYK = targetColorSpace.model == .cmyk
        let bytesPerRow = width * 4
        let bitmapInfo = isCMYK
            ? CGImageAlphaInfo.none.rawValue
            : CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: targetColorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw ConversionEngineError.encodeFailed
        }

        context.draw(image.cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let normalized = context.makeImage() else {
            throw ConversionEngineError.encodeFailed
        }

        return DecodedRasterImage(cgImage: normalized)
    }

    func resolvedOutputColorSpace(for intent: ConversionIntent) -> CGColorSpace {
        switch intent.options.outputColorSpace {
        case .sRGB:
            return CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        case .displayP3:
            return CGColorSpace(name: CGColorSpace.displayP3) ?? CGColorSpaceCreateDeviceRGB()
        case .cmyk:
            let capabilities = FormatCapabilityRegistry.capabilities(for: intent.targetFormat)
            if capabilities.supportsCMYKEncoding {
                return CGColorSpaceCreateDeviceCMYK()
            }
            return CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        }
    }
}
