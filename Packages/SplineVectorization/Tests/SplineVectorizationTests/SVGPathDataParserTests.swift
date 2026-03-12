import CoreGraphics
import XCTest
@testable import SplineVectorization

final class SVGPathDataParserTests: XCTestCase {
    func testArcCommandProducesCubicSegments() throws {
        let parser = SVGPathDataParser(pathData: "M 10 10 A 8 8 0 0 1 20 20")
        let commands = parser.parseCommands()

        XCTAssertFalse(commands.isEmpty)
        XCTAssertEqual(commands.first, .moveTo(CGPoint(x: 10, y: 10)))

        let hasCubic = commands.contains { command in
            if case .cubicCurveTo = command {
                return true
            }
            return false
        }

        XCTAssertTrue(hasCubic)
    }
}
