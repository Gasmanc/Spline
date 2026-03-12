import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class SplineConversionEngineTests: XCTestCase {
    func testPlannerPrefersVectorPreservationWhenSourceIsVectorAndTargetSVG() throws {
        let planner = ConversionGraphPlanner()
        let intent = ConversionIntent(
            sourceFormat: .pdf,
            targetFormat: .svg,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .displayP3)
        )

        let plan = planner.plan(for: intent)

        XCTAssertEqual(plan.steps, [.decodeVector, .preserveVectorToSVG, .normalizeColor, .encodeVector, .stripMetadata])
        XCTAssertFalse(plan.warnings.contains(.vectorPreservationUnavailable))
    }

    func testPlannerUsesRasterTraceWhenSourceIsRasterToSVG() throws {
        let planner = ConversionGraphPlanner()
        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .svg,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        let plan = planner.plan(for: intent)

        XCTAssertEqual(plan.steps, [.decodeRaster, .traceRasterToSVG, .normalizeColor, .encodeVector, .stripMetadata])
    }

    func testPlannerIncludesAnimationSelectionStepWhenInputMarkedAnimated() throws {
        let planner = ConversionGraphPlanner()
        let intent = ConversionIntent(
            sourceFormat: .gif,
            targetFormat: .png,
            containsAlphaChannel: false,
            containsAnimation: true,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        let plan = planner.plan(for: intent)
        XCTAssertTrue(plan.steps.contains(.selectAnimationFrames))
    }

    func testPlanScorerRewardsVectorPreservation() throws {
        let planner = ConversionGraphPlanner()
        let intent = ConversionIntent(
            sourceFormat: .svg,
            targetFormat: .svg,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        let plan = planner.plan(for: intent)
        let score = ConversionPlanScorer.score(plan: plan, intent: intent)

        XCTAssertGreaterThanOrEqual(score.fidelity, 110)
        XCTAssertGreaterThanOrEqual(score.determinism, 95)
    }
}
