import Foundation
import SplineDomain

public struct ConversionPlanScore: Sendable, Equatable {
    public let fidelity: Int
    public let determinism: Int
    public let complexity: Int

    public init(fidelity: Int, determinism: Int, complexity: Int) {
        self.fidelity = fidelity
        self.determinism = determinism
        self.complexity = complexity
    }
}

public enum ConversionPlanScorer {
    public static func score(plan: ConversionPlan, intent: ConversionIntent) -> ConversionPlanScore {
        let fidelity = fidelityScore(plan: plan, intent: intent)
        let determinism = determinismScore(plan: plan, intent: intent)
        let complexity = plan.steps.count
        return ConversionPlanScore(fidelity: fidelity, determinism: determinism, complexity: complexity)
    }

    private static func fidelityScore(plan: ConversionPlan, intent: ConversionIntent) -> Int {
        var score = 100
        if plan.warnings.contains(.alphaWillBeDiscarded) {
            score -= 25
        }
        if plan.warnings.contains(.animationWillBeReduced) {
            score -= 15
        }
        if plan.warnings.contains(.vectorPreservationUnavailable) {
            score -= 10
        }
        if intent.targetFormat == .svg && plan.steps.contains(.preserveVectorToSVG) {
            score += 20
        }
        return max(score, 0)
    }

    private static func determinismScore(plan: ConversionPlan, intent: ConversionIntent) -> Int {
        var score = intent.options.requireDeterministicOutput ? 100 : 75
        if plan.steps.contains(.selectAnimationFrames) {
            score -= 10
        }
        if plan.steps.contains(.traceRasterToSVG) {
            score -= 5
        }
        return max(score, 0)
    }
}
