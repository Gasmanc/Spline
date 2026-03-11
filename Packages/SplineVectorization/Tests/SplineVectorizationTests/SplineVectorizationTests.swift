import CoreGraphics
import XCTest
@testable import SplineVectorization
import SplineDomain

final class SplineVectorizationTests: XCTestCase {
    func testBlackAndWhiteTracingCreatesRectElements() throws {
        let image = try makeImage(width: 2, height: 1, pixels: [
            255, 255, 255, 255,
            0, 0, 0, 255
        ])

        let tracer = RasterSVGTracer()
        let svg = try tracer.trace(
            image: image,
            mode: .blackAndWhite,
            controls: TraceControls(threshold: 0.5)
        )

        XCTAssertTrue(svg.contains("<svg"))
        XCTAssertTrue(svg.contains("#FFFFFF"))
        XCTAssertTrue(svg.contains("#000000"))
    }

    private func makeImage(width: Int, height: Int, pixels: [UInt8]) throws -> CGImage {
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

        guard let data = context.data else {
            throw SVGTraceError.decodeFailed
        }

        let pointer = data.bindMemory(to: UInt8.self, capacity: pixels.count)
        for (index, value) in pixels.enumerated() {
            pointer[index] = value
        }

        guard let image = context.makeImage() else {
            throw SVGTraceError.decodeFailed
        }

        return image
    }
}
