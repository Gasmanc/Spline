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
        _ = namespaceURI
        _ = qName
        _ = parser

        if parseCanvas(elementName: elementName, attributes: attributeDict) {
            return
        }

        if parseRectangle(elementName: elementName, attributes: attributeDict) {
            return
        }

        if parseCircle(elementName: elementName, attributes: attributeDict) {
            return
        }

        if parseLine(elementName: elementName, attributes: attributeDict) {
            return
        }

        _ = parsePath(elementName: elementName, attributes: attributeDict)
    }

    private func parseCanvas(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "svg" else {
            return false
        }

        let width = Int(parseLength(attributes["width"]) ?? 512)
        let height = Int(parseLength(attributes["height"]) ?? 512)
        canvasSize = SVGCanvasSize(width: max(width, 1), height: max(height, 1))
        return true
    }

    private func parseRectangle(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "rect" else {
            return false
        }

        let originX = parseLength(attributes["x"]) ?? 0
        let originY = parseLength(attributes["y"]) ?? 0
        let width = parseLength(attributes["width"]) ?? 0
        let height = parseLength(attributes["height"]) ?? 0
        let fill = attributes["fill"] ?? "#000000"

        rectangles.append(
            SVGRectangle(
                originX: originX,
                originY: originY,
                width: width,
                height: height,
                fillHex: fill
            )
        )

        return true
    }

    private func parseCircle(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "circle" else {
            return false
        }

        let centerX = parseLength(attributes["cx"]) ?? 0
        let centerY = parseLength(attributes["cy"]) ?? 0
        let radius = parseLength(attributes["r"]) ?? 0
        let fill = attributes["fill"] ?? "#000000"

        circles.append(
            SVGCircle(
                centerX: centerX,
                centerY: centerY,
                radius: radius,
                fillHex: fill
            )
        )

        return true
    }

    private func parseLine(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "line" else {
            return false
        }

        let startX = parseLength(attributes["x1"]) ?? 0
        let startY = parseLength(attributes["y1"]) ?? 0
        let endX = parseLength(attributes["x2"]) ?? 0
        let endY = parseLength(attributes["y2"]) ?? 0
        let stroke = attributes["stroke"] ?? "#000000"
        let strokeWidth = parseLength(attributes["stroke-width"]) ?? 1

        lines.append(
            SVGLine(
                startX: startX,
                startY: startY,
                endX: endX,
                endY: endY,
                strokeHex: stroke,
                strokeWidth: strokeWidth
            )
        )

        return true
    }

    private func parsePath(elementName: String, attributes: [String: String]) -> Bool {
        guard elementName == "path", let pathData = attributes["d"] else {
            return false
        }

        let commands = parsePathData(pathData)
        let fill = attributes["fill"] ?? "#000000"
        let stroke = attributes["stroke"] ?? "#000000"
        let strokeWidth = parseLength(attributes["stroke-width"]) ?? 1
        let hasFill = fill.lowercased() != "none"

        paths.append(
            SVGPathShape(
                commands: commands,
                fillHex: fill,
                strokeHex: stroke,
                strokeWidth: strokeWidth,
                hasFill: hasFill
            )
        )

        return true
    }

    private func parsePathData(_ pathData: String) -> [SVGPathCommand] {
        let normalized = pathData
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: "M", with: " M ")
            .replacingOccurrences(of: "L", with: " L ")
            .replacingOccurrences(of: "Z", with: " Z ")
            .replacingOccurrences(of: "m", with: " m ")
            .replacingOccurrences(of: "l", with: " l ")
            .replacingOccurrences(of: "z", with: " z ")

        let tokens = normalized.split(whereSeparator: \.isWhitespace).map(String.init)
        var commands: [SVGPathCommand] = []
        var index = 0

        while index < tokens.count {
            let token = tokens[index]

            if token == "M" || token == "m" {
                if let command = parsePointCommand(tokens: tokens, index: index, kind: .moveTo) {
                    commands.append(command.command)
                    index = command.nextIndex
                    continue
                }
                break
            }

            if token == "L" || token == "l" {
                if let command = parsePointCommand(tokens: tokens, index: index, kind: .lineTo) {
                    commands.append(command.command)
                    index = command.nextIndex
                    continue
                }
                break
            }

            if token == "Z" || token == "z" {
                commands.append(.close)
                index += 1
                continue
            }

            index += 1
        }

        return commands
    }

    private func parsePointCommand(
        tokens: [String],
        index: Int,
        kind: PathPointCommand
    ) -> (command: SVGPathCommand, nextIndex: Int)? {
        guard index + 2 < tokens.count,
              let xValue = Double(tokens[index + 1]),
              let yValue = Double(tokens[index + 2]) else {
            return nil
        }

        let point = CGPoint(x: xValue, y: yValue)
        switch kind {
        case .moveTo:
            return (.moveTo(point), index + 3)
        case .lineTo:
            return (.lineTo(point), index + 3)
        }
    }

    private func parseLength(_ value: String?) -> CGFloat? {
        guard let value else {
            return nil
        }

        let filtered = value.filter { "0123456789.-".contains($0) }
        guard let number = Double(filtered) else {
            return nil
        }

        return CGFloat(number)
    }

    private enum PathPointCommand {
        case moveTo
        case lineTo
    }
}
