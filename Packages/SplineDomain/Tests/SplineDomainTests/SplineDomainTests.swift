import XCTest
@testable import SplineDomain

final class SplineDomainTests: XCTestCase {
    func testPolicyWarningsWhenTargetLosesAlphaAndAnimation() throws {
        let intent = ConversionIntent(
            sourceFormat: .webp,
            targetFormat: .jpeg,
            containsAlphaChannel: true,
            containsAnimation: true,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        let warnings = ConversionPolicyEvaluator.warnings(for: intent)

        XCTAssertTrue(warnings.contains(.alphaWillBeDiscarded))
        XCTAssertTrue(warnings.contains(.animationWillBeReduced))
    }

    func testNoVectorWarningForVectorSourceToSVG() throws {
        let intent = ConversionIntent(
            sourceFormat: .pdf,
            targetFormat: .svg,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .displayP3)
        )

        let warnings = ConversionPolicyEvaluator.warnings(for: intent)

        XCTAssertFalse(warnings.contains(.vectorPreservationUnavailable))
    }

    func testCMYKWarningWhenTargetCannotEncodeCMYK() throws {
        let intent = ConversionIntent(
            sourceFormat: .tiff,
            targetFormat: .png,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .cmyk)
        )

        let warnings = ConversionPolicyEvaluator.warnings(for: intent)

        XCTAssertEqual(warnings, [.cmykNotSupportedByTarget])
    }
}
