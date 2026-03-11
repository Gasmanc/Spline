import Foundation
import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class FileConversionServiceTests: XCTestCase {
    func testConvertRejectsVectorTargetDuringCurrentPhase() throws {
        let service = FileConversionService()

        let inputURL = URL(fileURLWithPath: "/tmp/in.png")
        let outputURL = URL(fileURLWithPath: "/tmp/out.svg")
        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .svg,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        XCTAssertThrowsError(try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)) { error in
            XCTAssertEqual(error as? ConversionEngineError, .unsupportedFormat)
        }
    }
}
