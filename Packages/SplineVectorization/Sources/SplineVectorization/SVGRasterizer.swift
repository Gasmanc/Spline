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

        let context = try makeContext(canvas: parserDelegate.canvasSize)
        clearCanvas(context, canvas: parserDelegate.canvasSize)

        drawRectangles(parserDelegate.rectangles, context: context)
        drawCircles(parserDelegate.circles, context: context)
        drawLines(parserDelegate.lines, context: context)
        drawPaths(parserDelegate.paths, context: context)

        guard let image = context.makeImage() else {
            throw SVGTraceError.decodeFailed
        }

        return image
    }

    private func makeContext(canvas: SVGCanvasSize) throws -> CGContext {
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

        return context
    }

    private func clearCanvas(_ context: CGContext, canvas: SVGCanvasSize) {
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0)
        context.fill(
            CGRect(
                x: 0,
                y: 0,
                width: max(canvas.width, 1),
                height: max(canvas.height, 1)
            )
        )
    }

    private func drawRectangles(_ rectangles: [SVGRectangle], context: CGContext) {
        for rectangle in rectangles {
            let fillColor = parseHexColor(rectangle.fillHex)
            context.setFillColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
            context.fill(
                CGRect(
                    x: rectangle.originX,
                    y: rectangle.originY,
                    width: rectangle.width,
                    height: rectangle.height
                )
            )
        }
    }

    private func drawCircles(_ circles: [SVGCircle], context: CGContext) {
        for circle in circles {
            let fillColor = parseHexColor(circle.fillHex)
            context.setFillColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
            let rect = CGRect(
                x: circle.centerX - circle.radius,
                y: circle.centerY - circle.radius,
                width: circle.radius * 2,
                height: circle.radius * 2
            )
            context.fillEllipse(in: rect)
        }
    }

    private func drawLines(_ lines: [SVGLine], context: CGContext) {
        for line in lines {
            let strokeColor = parseHexColor(line.strokeHex)
            context.setStrokeColor(red: strokeColor.red, green: strokeColor.green, blue: strokeColor.blue, alpha: strokeColor.alpha)
            context.setLineWidth(max(line.strokeWidth, 1))
            context.beginPath()
            context.move(to: CGPoint(x: line.startX, y: line.startY))
            context.addLine(to: CGPoint(x: line.endX, y: line.endY))
            context.strokePath()
        }
    }

    private func drawPaths(_ paths: [SVGPathShape], context: CGContext) {
        for path in paths {
            draw(path: path, context: context)
        }
    }

    private func draw(path: SVGPathShape, context: CGContext) {
        let fillColor = parseHexColor(path.fillHex)
        let strokeColor = parseHexColor(path.strokeHex)

        context.beginPath()
        for command in path.commands {
            switch command {
            case let .moveTo(point):
                context.move(to: point)
            case let .lineTo(point):
                context.addLine(to: point)
            case let .cubicCurveTo(control1, control2, end):
                context.addCurve(to: end, control1: control1, control2: control2)
            case let .quadCurveTo(control, end):
                context.addQuadCurve(to: end, control: control)
            case .close:
                context.closePath()
            }
        }

        context.setFillColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
        context.setStrokeColor(red: strokeColor.red, green: strokeColor.green, blue: strokeColor.blue, alpha: strokeColor.alpha)
        context.setLineWidth(max(path.strokeWidth, 1))

        if path.hasFill {
            context.drawPath(using: .fillStroke)
        } else {
            context.drawPath(using: .stroke)
        }
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
