import CoreGraphics
import Foundation
import SplineDomain

public struct RasterSVGTracer: Sendable {
    public init() {}

    public func trace(image: CGImage, mode: TraceMode, controls: TraceControls) throws -> String {
        let width = image.width
        let height = image.height

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw SVGTraceError.decodeFailed
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else {
            throw SVGTraceError.decodeFailed
        }

        let matrix = PixelMatrix(
            pointer: data.bindMemory(to: UInt8.self, capacity: width * height * 4),
            width: width,
            mode: mode,
            controls: controls
        )

        var lines: [String] = [
            "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 \(width) \(height)\" width=\"\(width)\" height=\"\(height)\">"
        ]

        for yIndex in 0..<height {
            var xIndex = 0
            while xIndex < width {
                let color = pixelColor(atX: xIndex, y: yIndex, matrix: matrix)
                var runLength = 1

                while xIndex + runLength < width {
                    let nextColor = pixelColor(atX: xIndex + runLength, y: yIndex, matrix: matrix)
                    if nextColor != color {
                        break
                    }
                    runLength += 1
                }

                if color.alpha > 0 {
                    lines.append(rectElement(xIndex: xIndex, yIndex: yIndex, runWidth: runLength, color: color))
                }

                xIndex += runLength
            }
        }

        lines.append("</svg>")
        return lines.joined(separator: "\n")
    }

    private func rectElement(xIndex: Int, yIndex: Int, runWidth: Int, color: PixelColor) -> String {
        if color.alpha < 1 {
            let alphaValue = String(format: "%.3f", color.alpha)
            return "<rect x=\"\(xIndex)\" y=\"\(yIndex)\" width=\"\(runWidth)\" height=\"1\" " +
                "fill=\"\(color.hex)\" fill-opacity=\"\(alphaValue)\"/>"
        }

        return "<rect x=\"\(xIndex)\" y=\"\(yIndex)\" width=\"\(runWidth)\" height=\"1\" fill=\"\(color.hex)\"/>"
    }

    private func pixelColor(atX xIndex: Int, y yIndex: Int, matrix: PixelMatrix) -> PixelColor {
        let offset = ((yIndex * matrix.width) + xIndex) * 4
        let redChannel = matrix.pointer[offset]
        let greenChannel = matrix.pointer[offset + 1]
        let blueChannel = matrix.pointer[offset + 2]
        let alphaChannel = matrix.pointer[offset + 3]

        switch matrix.mode {
        case .color:
            let quantized = quantize(
                redChannel: redChannel,
                greenChannel: greenChannel,
                blueChannel: blueChannel,
                control: matrix.controls.pathSimplification
            )
            return PixelColor(
                red: quantized.red,
                green: quantized.green,
                blue: quantized.blue,
                alpha: Double(alphaChannel) / 255.0
            )
        case .blackAndWhite:
            let luminance =
                (0.299 * Double(redChannel)) +
                (0.587 * Double(greenChannel)) +
                (0.114 * Double(blueChannel))
            let threshold = max(0, min(1, Double(matrix.controls.threshold))) * 255
            let value: UInt8 = luminance >= threshold ? 255 : 0
            return PixelColor(red: value, green: value, blue: value, alpha: Double(alphaChannel) / 255.0)
        }
    }

    private func quantize(
        redChannel: UInt8,
        greenChannel: UInt8,
        blueChannel: UInt8,
        control: Float
    ) -> PixelRGB {
        let bucket = max(1, Int((1 - min(max(control, 0), 1)) * 32))
        return PixelRGB(
            red: UInt8((Int(redChannel) / bucket) * bucket),
            green: UInt8((Int(greenChannel) / bucket) * bucket),
            blue: UInt8((Int(blueChannel) / bucket) * bucket)
        )
    }
}

private struct PixelMatrix {
    let pointer: UnsafeMutablePointer<UInt8>
    let width: Int
    let mode: TraceMode
    let controls: TraceControls
}

private struct PixelRGB {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
}

private struct PixelColor: Equatable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: Double

    var hex: String {
        String(format: "#%02X%02X%02X", red, green, blue)
    }
}
