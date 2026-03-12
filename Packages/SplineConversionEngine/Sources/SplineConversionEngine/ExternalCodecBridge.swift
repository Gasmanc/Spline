import CoreGraphics
import Foundation
import ImageIO
import CWebPBridge
import CAVIFBridge

enum ExternalCodecBridge {
    static func decodeWebP(data: Data) throws -> DecodedRasterImage {
        var pointer: UnsafeMutablePointer<UInt8>?
        var width: Int32 = 0
        var height: Int32 = 0

        let success: Int32 = data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }
            return spline_webp_decode_rgba(base, data.count, &pointer, &width, &height)
        }

        guard success == 1, let outputPointer = pointer else {
            throw ConversionEngineError.decodeFailed
        }
        defer { spline_webp_free(outputPointer) }

        let outputData = Data(bytes: outputPointer, count: Int(width * height * 4))
        let image = try makeCGImageFromRGBA(data: outputData, width: Int(width), height: Int(height))
        return DecodedRasterImage(cgImage: image)
    }

    static func encodeWebP(image: DecodedRasterImage, quality: Float = 90) throws -> Data {
        let rgba = try makeRGBAFromCGImage(image.cgImage)

        var pointer: UnsafeMutablePointer<UInt8>?
        var outputLength: Int = 0

        let success: Int32 = rgba.data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }

            return spline_webp_encode_rgba(
                base,
                Int32(rgba.width),
                Int32(rgba.height),
                Int32(rgba.bytesPerRow),
                quality,
                &pointer,
                &outputLength
            )
        }

        guard success == 1, let outputPointer = pointer else {
            throw ConversionEngineError.encodeFailed
        }
        defer { spline_webp_free(outputPointer) }

        return Data(bytes: outputPointer, count: outputLength)
    }

    static func decodeAVIF(data: Data) throws -> DecodedRasterImage {
        var pointer: UnsafeMutablePointer<UInt8>?
        var width: Int32 = 0
        var height: Int32 = 0

        let success: Int32 = data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }
            return spline_avif_decode_rgba(base, data.count, &pointer, &width, &height)
        }

        guard success == 1, let outputPointer = pointer else {
            throw ConversionEngineError.decodeFailed
        }
        defer { spline_avif_free(outputPointer) }

        let outputData = Data(bytes: outputPointer, count: Int(width * height * 4))
        let image = try makeCGImageFromRGBA(data: outputData, width: Int(width), height: Int(height))
        return DecodedRasterImage(cgImage: image)
    }

    static func encodeAVIF(image: DecodedRasterImage, quality: Int = 85) throws -> Data {
        let rgba = try makeRGBAFromCGImage(image.cgImage)

        var pointer: UnsafeMutablePointer<UInt8>?
        var outputLength: Int = 0

        let success: Int32 = rgba.data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }

            return spline_avif_encode_rgba(
                base,
                Int32(rgba.width),
                Int32(rgba.height),
                Int32(rgba.bytesPerRow),
                Int32(quality),
                &pointer,
                &outputLength
            )
        }

        guard success == 1, let outputPointer = pointer else {
            throw ConversionEngineError.encodeFailed
        }
        defer { spline_avif_free(outputPointer) }

        return Data(bytes: outputPointer, count: outputLength)
    }

    private static func makeRGBAFromCGImage(_ image: CGImage) throws -> RGBAImageBuffer {
        let width = image.width
        let height = image.height
        let bytesPerRow = width * 4

        var data = Data(count: bytesPerRow * height)
        let drawSucceeded = data.withUnsafeMutableBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else {
                return false
            }

            guard let context = CGContext(
                data: base,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }

            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }

        guard drawSucceeded else {
            throw ConversionEngineError.encodeFailed
        }

        return RGBAImageBuffer(data: data, width: width, height: height, bytesPerRow: bytesPerRow)
    }

    private static func makeCGImageFromRGBA(data: Data, width: Int, height: Int) throws -> CGImage {
        guard let provider = CGDataProvider(data: data as CFData) else {
            throw ConversionEngineError.decodeFailed
        }

        guard let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            throw ConversionEngineError.decodeFailed
        }

        return image
    }
}

private struct RGBAImageBuffer {
    let data: Data
    let width: Int
    let height: Int
    let bytesPerRow: Int
}
