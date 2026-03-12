import XCTest
@testable import SplineUI
import SplineDomain

final class SplineUITests: XCTestCase {
    func testFormModelBuildsIntent() throws {
        let model = ConversionFormModel(
            sourceFormat: .png,
            targetFormat: .svg,
            outputColorSpace: .displayP3,
            traceMode: .color,
            svgMode: .forceRasterTrace
        )

        let intent = model.makeIntent(containsAlphaChannel: true, containsAnimation: false)

        XCTAssertEqual(intent.sourceFormat, .png)
        XCTAssertEqual(intent.targetFormat, .svg)
        XCTAssertEqual(intent.options.outputColorSpace, .displayP3)
        XCTAssertEqual(intent.options.traceMode, .color)
        XCTAssertEqual(intent.options.svgMode, .forceRasterTrace)
    }
}
