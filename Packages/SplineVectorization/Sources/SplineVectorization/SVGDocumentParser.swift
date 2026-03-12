import CoreGraphics
import Foundation

struct SVGRectangle {
    let originX: CGFloat
    let originY: CGFloat
    let width: CGFloat
    let height: CGFloat
    let fillHex: String
}

struct SVGCircle {
    let centerX: CGFloat
    let centerY: CGFloat
    let radius: CGFloat
    let fillHex: String
}

struct SVGLine {
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let strokeHex: String
    let strokeWidth: CGFloat
}

enum SVGPathCommand {
    case moveTo(CGPoint)
    case lineTo(CGPoint)
    case cubicCurveTo(control1: CGPoint, control2: CGPoint, end: CGPoint)
    case quadCurveTo(control: CGPoint, end: CGPoint)
    case close
}

struct SVGPathShape {
    let commands: [SVGPathCommand]
    let fillHex: String
    let strokeHex: String
    let strokeWidth: CGFloat
    let hasFill: Bool
}

struct SVGCanvasSize {
    let width: Int
    let height: Int
}

final class SVGDocumentParser: NSObject, XMLParserDelegate {
    var canvasSize = SVGCanvasSize(width: 512, height: 512)
    var rectangles: [SVGRectangle] = []
    var circles: [SVGCircle] = []
    var lines: [SVGLine] = []
    var paths: [SVGPathShape] = []

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        _ = parser
        _ = namespaceURI
        _ = qName

        if parseCanvas(elementName: elementName, attributes: attributeDict) { return }
        if parseRectangle(elementName: elementName, attributes: attributeDict) { return }
        if parseCircle(elementName: elementName, attributes: attributeDict) { return }
        if parseLine(elementName: elementName, attributes: attributeDict) { return }
        _ = parsePath(elementName: elementName, attributes: attributeDict)
    }

    private func parseCanvas(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "svg" else { return false }

        let width = Int(parseLength(attributes["width"]) ?? 512)
        let height = Int(parseLength(attributes["height"]) ?? 512)
        canvasSize = SVGCanvasSize(width: max(width, 1), height: max(height, 1))
        return true
    }

    private func parseRectangle(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "rect" else { return false }

        rectangles.append(
            SVGRectangle(
                originX: parseLength(attributes["x"]) ?? 0,
                originY: parseLength(attributes["y"]) ?? 0,
                width: parseLength(attributes["width"]) ?? 0,
                height: parseLength(attributes["height"]) ?? 0,
                fillHex: attributes["fill"] ?? "#000000"
            )
        )

        return true
    }

    private func parseCircle(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "circle" else { return false }

        circles.append(
            SVGCircle(
                centerX: parseLength(attributes["cx"]) ?? 0,
                centerY: parseLength(attributes["cy"]) ?? 0,
                radius: parseLength(attributes["r"]) ?? 0,
                fillHex: attributes["fill"] ?? "#000000"
            )
        )

        return true
    }

    private func parseLine(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "line" else { return false }

        lines.append(
            SVGLine(
                startX: parseLength(attributes["x1"]) ?? 0,
                startY: parseLength(attributes["y1"]) ?? 0,
                endX: parseLength(attributes["x2"]) ?? 0,
                endY: parseLength(attributes["y2"]) ?? 0,
                strokeHex: attributes["stroke"] ?? "#000000",
                strokeWidth: parseLength(attributes["stroke-width"]) ?? 1
            )
        )

        return true
    }

    private func parsePath(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "path", let pathData = attributes["d"] else { return false }

        paths.append(
            SVGPathShape(
                commands: SVGPathDataParser(pathData: pathData).parseCommands(),
                fillHex: attributes["fill"] ?? "#000000",
                strokeHex: attributes["stroke"] ?? "#000000",
                strokeWidth: parseLength(attributes["stroke-width"]) ?? 1,
                hasFill: (attributes["fill"] ?? "#000000").lowercased() != "none"
            )
        )

        return true
    }

    private func parseLength(_ value: String?) -> CGFloat? {
        guard let value else { return nil }
        let filtered = value.filter { "0123456789.-".contains($0) }
        guard let number = Double(filtered) else { return nil }
        return CGFloat(number)
    }
}
