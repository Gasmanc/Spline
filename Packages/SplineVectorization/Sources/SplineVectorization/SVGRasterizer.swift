import CoreGraphics
import Foundation

public struct SVGRasterizer: Sendable {
    public init() {}

    public func rasterize(inputURL: URL) throws -> CGImage {
        let data = try Data(contentsOf: inputURL)
        let parserDelegate = SVGDocumentParser()
        let parser = XMLParser(data: data)
        parser.delegate = parserDelegate

        guard parser.parse() else {
            throw SVGTraceError.decodeFailed
        }

        let canvas = parserDelegate.canvasSize
        let width = max(canvas.width, 1)
        let height = max(canvas.height, 1)

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

        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        for rectangle in parserDelegate.rectangles {
            let color = parseHexColor(rectangle.fillHex)
            context.setFillColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
            context.fill(
                CGRect(
                    x: rectangle.originX,
                    y: rectangle.originY,
                    width: rectangle.width,
                    height: rectangle.height
                )
            )
        }

        guard let image = context.makeImage() else {
            throw SVGTraceError.decodeFailed
        }

        return image
    }

    private func parseHexColor(_ hex: String) -> RGBAColor {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        guard sanitized.count == 6, let value = UInt32(sanitized, radix: 16) else {
            return RGBAColor(red: 0, green: 0, blue: 0, alpha: 1)
        }

        let redValue = CGFloat((value >> 16) & 0xFF) / 255.0
        let greenValue = CGFloat((value >> 8) & 0xFF) / 255.0
        let blueValue = CGFloat(value & 0xFF) / 255.0
        return RGBAColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
    }
}

private struct RGBAColor {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

private final class SVGDocumentParser: NSObject, XMLParserDelegate {
    struct Rectangle {
        let originX: CGFloat
        let originY: CGFloat
        let width: CGFloat
        let height: CGFloat
        let fillHex: String
    }

    struct CanvasSize {
        let width: Int
        let height: Int
    }

    var canvasSize = CanvasSize(width: 512, height: 512)
    var rectangles: [Rectangle] = []

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        _ = namespaceURI
        _ = qName
        _ = parser

        if elementName == "svg" {
            let width = Int(parseLength(attributeDict["width"]) ?? 512)
            let height = Int(parseLength(attributeDict["height"]) ?? 512)
            canvasSize = CanvasSize(width: max(width, 1), height: max(height, 1))
            return
        }

        if elementName == "rect" {
            let originX = parseLength(attributeDict["x"]) ?? 0
            let originY = parseLength(attributeDict["y"]) ?? 0
            let width = parseLength(attributeDict["width"]) ?? 0
            let height = parseLength(attributeDict["height"]) ?? 0
            let fill = attributeDict["fill"] ?? "#000000"

            rectangles.append(
                Rectangle(
                    originX: originX,
                    originY: originY,
                    width: width,
                    height: height,
                    fillHex: fill
                )
            )
        }
    }

    private func parseLength(_ value: String?) -> CGFloat? {
        guard let value else {
            return nil
        }

        let filtered = value.filter { "0123456789.".contains($0) }
        guard let number = Double(filtered) else {
            return nil
        }

        return CGFloat(number)
    }
}
