import CoreGraphics
import Foundation

struct SVGArcInput {
    let start: CGPoint
    let end: CGPoint
    let radiusX: CGFloat
    let radiusY: CGFloat
    let xAxisRotationDegrees: CGFloat
    let largeArc: Bool
    let sweep: Bool
}

private struct ArcCenterContext {
    let xPrime: CGFloat
    let yPrime: CGFloat
    let radiusX: CGFloat
    let radiusY: CGFloat
    let largeArc: Bool
    let sweep: Bool
}

private struct ArcCenterTransform {
    let centerPrime: CGPoint
    let cosPhi: CGFloat
    let sinPhi: CGFloat
    let start: CGPoint
    let end: CGPoint
}

private struct ArcAngleInput {
    let xPrime: CGFloat
    let yPrime: CGFloat
    let centerPrime: CGPoint
    let radiusX: CGFloat
    let radiusY: CGFloat
    let sweep: Bool
}

private struct ArcSegmentInput {
    let center: CGPoint
    let radiusX: CGFloat
    let radiusY: CGFloat
    let phi: CGFloat
    let startAngle: CGFloat
    let deltaAngle: CGFloat
}

private struct CubicSegment {
    let control1: CGPoint
    let control2: CGPoint
    let end: CGPoint
}

private struct ArcSegmentGeometry {
    let center: CGPoint
    let radiusX: CGFloat
    let radiusY: CGFloat
    let phi: CGFloat
    let fromAngle: CGFloat
    let toAngle: CGFloat
}

enum SVGArcConverter {
    static func commands(for input: SVGArcInput) -> [SVGPathCommand] {
        guard let built = buildArcSegmentsInput(from: input) else {
            return [.lineTo(input.end)]
        }
        return arcSegmentsAsCubic(input: built)
    }

    private static func buildArcSegmentsInput(from input: SVGArcInput) -> ArcSegmentInput? {
        var radii = normalizedRadii(radiusX: input.radiusX, radiusY: input.radiusY)
        guard radii.radiusX > 0, radii.radiusY > 0 else {
            return nil
        }

        let phi = input.xAxisRotationDegrees * .pi / 180
        let rotation = (cos: cos(phi), sin: sin(phi))
        let prime = primeCoordinates(start: input.start, end: input.end, rotation: rotation)

        let lambda = (prime.x * prime.x) / (radii.radiusX * radii.radiusX) +
            (prime.y * prime.y) / (radii.radiusY * radii.radiusY)
        if lambda > 1 {
            let scale = sqrt(lambda)
            radii = (radii.radiusX * scale, radii.radiusY * scale)
        }

        let centerPrime = arcCenterPrime(
            context: ArcCenterContext(
                xPrime: prime.x,
                yPrime: prime.y,
                radiusX: radii.radiusX,
                radiusY: radii.radiusY,
                largeArc: input.largeArc,
                sweep: input.sweep
            )
        )

        let center = arcCenter(
            transform: ArcCenterTransform(
                centerPrime: centerPrime,
                cosPhi: rotation.cos,
                sinPhi: rotation.sin,
                start: input.start,
                end: input.end
            )
        )

        let angles = arcAngles(
            input: ArcAngleInput(
                xPrime: prime.x,
                yPrime: prime.y,
                centerPrime: centerPrime,
                radiusX: radii.radiusX,
                radiusY: radii.radiusY,
                sweep: input.sweep
            )
        )

        return ArcSegmentInput(
            center: center,
            radiusX: radii.radiusX,
            radiusY: radii.radiusY,
            phi: phi,
            startAngle: angles.start,
            deltaAngle: angles.delta
        )
    }

    private static func normalizedRadii(radiusX: CGFloat, radiusY: CGFloat) -> (radiusX: CGFloat, radiusY: CGFloat) {
        (abs(radiusX), abs(radiusY))
    }

    private static func primeCoordinates(
        start: CGPoint,
        end: CGPoint,
        rotation: (cos: CGFloat, sin: CGFloat)
    ) -> (x: CGFloat, y: CGFloat) {
        let midpointX = (start.x - end.x) / 2
        let midpointY = (start.y - end.y) / 2

        let xPrime = (rotation.cos * midpointX) + (rotation.sin * midpointY)
        let yPrime = (-rotation.sin * midpointX) + (rotation.cos * midpointY)
        return (xPrime, yPrime)
    }

    private static func arcCenterPrime(context: ArcCenterContext) -> CGPoint {
        let sign: CGFloat = context.largeArc == context.sweep ? -1 : 1

        let numerator = max(
            0,
            (context.radiusX * context.radiusX * context.radiusY * context.radiusY) -
                (context.radiusX * context.radiusX * context.yPrime * context.yPrime) -
                (context.radiusY * context.radiusY * context.xPrime * context.xPrime)
        )

        let denominator =
            (context.radiusX * context.radiusX * context.yPrime * context.yPrime) +
            (context.radiusY * context.radiusY * context.xPrime * context.xPrime)

        guard denominator != 0 else {
            return .zero
        }

        let coefficient = sign * sqrt(numerator / denominator)
        let centerXPrime = coefficient * ((context.radiusX * context.yPrime) / context.radiusY)
        let centerYPrime = coefficient * (-(context.radiusY * context.xPrime) / context.radiusX)

        return CGPoint(x: centerXPrime, y: centerYPrime)
    }

    private static func arcCenter(transform: ArcCenterTransform) -> CGPoint {
        let centerX =
            (transform.cosPhi * transform.centerPrime.x) -
            (transform.sinPhi * transform.centerPrime.y) +
            ((transform.start.x + transform.end.x) / 2)

        let centerY =
            (transform.sinPhi * transform.centerPrime.x) +
            (transform.cosPhi * transform.centerPrime.y) +
            ((transform.start.y + transform.end.y) / 2)

        return CGPoint(x: centerX, y: centerY)
    }

    private static func arcAngles(input: ArcAngleInput) -> (start: CGFloat, delta: CGFloat) {
        let unitStart = CGPoint(
            x: (input.xPrime - input.centerPrime.x) / input.radiusX,
            y: (input.yPrime - input.centerPrime.y) / input.radiusY
        )

        let unitEnd = CGPoint(
            x: (-input.xPrime - input.centerPrime.x) / input.radiusX,
            y: (-input.yPrime - input.centerPrime.y) / input.radiusY
        )

        let startAngle = vectorAngle(from: CGPoint(x: 1, y: 0), to: unitStart)
        var deltaAngle = vectorAngle(from: unitStart, to: unitEnd)

        if !input.sweep && deltaAngle > 0 {
            deltaAngle -= 2 * .pi
        } else if input.sweep && deltaAngle < 0 {
            deltaAngle += 2 * .pi
        }

        return (startAngle, deltaAngle)
    }

    private static func arcSegmentsAsCubic(input: ArcSegmentInput) -> [SVGPathCommand] {
        let segmentCount = max(1, Int(ceil(abs(input.deltaAngle) / (.pi / 2))))
        let segmentDelta = input.deltaAngle / CGFloat(segmentCount)

        var commands: [SVGPathCommand] = []
        var currentAngle = input.startAngle

        for _ in 0..<segmentCount {
            let nextAngle = currentAngle + segmentDelta
            let segment = arcSegmentToCubic(
                geometry: ArcSegmentGeometry(
                    center: input.center,
                    radiusX: input.radiusX,
                    radiusY: input.radiusY,
                    phi: input.phi,
                    fromAngle: currentAngle,
                    toAngle: nextAngle
                )
            )

            commands.append(
                .cubicCurveTo(
                    control1: segment.control1,
                    control2: segment.control2,
                    end: segment.end
                )
            )

            currentAngle = nextAngle
        }

        return commands
    }

    private static func arcSegmentToCubic(geometry: ArcSegmentGeometry) -> CubicSegment {
        let delta = geometry.toAngle - geometry.fromAngle
        let alpha = (4.0 / 3.0) * tan(delta / 4.0)

        let cosFrom = cos(geometry.fromAngle)
        let sinFrom = sin(geometry.fromAngle)
        let cosTo = cos(geometry.toAngle)
        let sinTo = sin(geometry.toAngle)

        let start = CGPoint(x: cosFrom, y: sinFrom)
        let end = CGPoint(x: cosTo, y: sinTo)

        let unitControl1 = CGPoint(
            x: start.x - alpha * start.y,
            y: start.y + alpha * start.x
        )

        let unitControl2 = CGPoint(
            x: end.x + alpha * end.y,
            y: end.y - alpha * end.x
        )

        let control1 = mapUnitPointToEllipse(
            unitControl1,
            center: geometry.center,
            radiusX: geometry.radiusX,
            radiusY: geometry.radiusY,
            phi: geometry.phi
        )
        let control2 = mapUnitPointToEllipse(
            unitControl2,
            center: geometry.center,
            radiusX: geometry.radiusX,
            radiusY: geometry.radiusY,
            phi: geometry.phi
        )
        let mappedEnd = mapUnitPointToEllipse(
            end,
            center: geometry.center,
            radiusX: geometry.radiusX,
            radiusY: geometry.radiusY,
            phi: geometry.phi
        )

        return CubicSegment(control1: control1, control2: control2, end: mappedEnd)
    }

    private static func mapUnitPointToEllipse(
        _ point: CGPoint,
        center: CGPoint,
        radiusX: CGFloat,
        radiusY: CGFloat,
        phi: CGFloat
    ) -> CGPoint {
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)

        let xCoordinate = center.x + radiusX * ((cosPhi * point.x) - (sinPhi * point.y))
        let yCoordinate = center.y + radiusY * ((sinPhi * point.x) + (cosPhi * point.y))

        return CGPoint(x: xCoordinate, y: yCoordinate)
    }

    private static func vectorAngle(from: CGPoint, to: CGPoint) -> CGFloat {
        let dot = (from.x * to.x) + (from.y * to.y)
        let cross = (from.x * to.y) - (from.y * to.x)
        return atan2(cross, dot)
    }
}
