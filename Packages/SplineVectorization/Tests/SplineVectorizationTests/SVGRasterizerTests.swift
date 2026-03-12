import Foundation
import XCTest
@testable import SplineVectorization

final class SVGRasterizerTests: XCTestCase {
    func testRasterizeSupportsRectCircleLineAndPath() throws {
        let svg = """
        <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\">
          <rect x=\"0\" y=\"0\" width=\"8\" height=\"8\" fill=\"#FF0000\"/>
          <circle cx=\"16\" cy=\"16\" r=\"6\" fill=\"#00FF00\"/>
          <line x1=\"0\" y1=\"31\" x2=\"31\" y2=\"0\" stroke=\"#0000FF\" stroke-width=\"2\"/>
          <path d=\"M 10 24 L 20 24 L 20 30 Z\" fill=\"#FFFF00\" stroke=\"#000000\" stroke-width=\"1\"/>
        </svg>
        """

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("rasterizer-test-\(UUID().uuidString).svg")
        try Data(svg.utf8).write(to: tempURL, options: .atomic)

        let rasterizer = SVGRasterizer()
        let image = try rasterizer.rasterize(inputURL: tempURL)

        XCTAssertEqual(image.width, 32)
        XCTAssertEqual(image.height, 32)
    }
}
