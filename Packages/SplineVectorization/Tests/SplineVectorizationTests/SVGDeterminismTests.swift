import CoreGraphics
import XCTest
@testable import SplineVectorization
import SplineDomain

final class SVGDeterminismTests: XCTestCase {
    func testTraceDeterministicForSameInput() throws {
        let image = try makeSolidImage(width: 3, height: 2, red: 12, green: 64, blue: 188)
        let tracer = RasterSVGTracer()

        let controls = TraceControls(threshold: 0.6, pathSimplification: 0.2)
        let first = try tracer.trace(image: image, mode: .color, controls: controls)
        let second = try tracer.trace(image: image, mode: .color, controls: controls)

        XCTAssertEqual(first, second)
    }

    private func makeSolidImage(width: Int, height: Int, red: UInt8, green: UInt8, blue: UInt8) throws -> CGImage {
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

        context.setFillColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        guard let image = context.makeImage() else {
            throw SVGTraceError.decodeFailed
        }

        return image
    }
}
