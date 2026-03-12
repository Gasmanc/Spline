import CoreGraphics
import Foundation
import XCTest
@testable import SplineVectorization

final class SVGPathConformanceFixtureTests: XCTestCase {
    func testPathConformanceFixtures() throws {
        let fixtureData = try loadFixtureData(
            name: "path-conformance",
            extension: "json"
        )

        let suite = try JSONDecoder().decode(PathConformanceSuite.self, from: fixtureData)
        XCTAssertFalse(suite.cases.isEmpty)

        for fixtureCase in suite.cases {
            let commands = SVGPathDataParser(pathData: fixtureCase.pathData).parseCommands()
            XCTAssertFalse(commands.isEmpty, "Expected parsed commands for fixture \(fixtureCase.id)")

            guard case let .moveTo(movePoint) = commands.first else {
                XCTFail("First command must be moveTo for fixture \(fixtureCase.id)")
                continue
            }

            assertEqual(movePoint, fixtureCase.expectedMove, message: "Unexpected move point for fixture \(fixtureCase.id)")

            let summary = summarize(commands: commands)
            XCTAssertGreaterThanOrEqual(
                summary.lineCount,
                fixtureCase.minimumLineCount,
                "Line count underflow for fixture \(fixtureCase.id)"
            )
            XCTAssertGreaterThanOrEqual(
                summary.cubicCount,
                fixtureCase.minimumCubicCount,
                "Cubic count underflow for fixture \(fixtureCase.id)"
            )
            XCTAssertGreaterThanOrEqual(
                summary.quadCount,
                fixtureCase.minimumQuadCount,
                "Quad count underflow for fixture \(fixtureCase.id)"
            )
            XCTAssertEqual(summary.hasClose, fixtureCase.expectsClose, "Close-command mismatch for fixture \(fixtureCase.id)")

            guard let finalPoint = finalPoint(from: commands) else {
                XCTFail("Expected final point for fixture \(fixtureCase.id)")
                continue
            }

            assertEqual(finalPoint, fixtureCase.expectedFinalPoint, message: "Unexpected final point for fixture \(fixtureCase.id)")
        }
    }

    func testRasterizerHandlesMixedCommandFixtureSVG() throws {
        let fixtureURL = try fixtureURL(
            name: "mixed-path-conformance",
            extension: "svg"
        )

        let image = try SVGRasterizer().rasterize(inputURL: fixtureURL)

        XCTAssertEqual(image.width, 64)
        XCTAssertEqual(image.height, 64)
    }

    private func summarize(commands: [SVGPathCommand]) -> CommandSummary {
        var lineCount = 0
        var cubicCount = 0
        var quadCount = 0
        var hasClose = false

        for command in commands {
            switch command {
            case .lineTo:
                lineCount += 1
            case .cubicCurveTo:
                cubicCount += 1
            case .quadCurveTo:
                quadCount += 1
            case .close:
                hasClose = true
            case .moveTo:
                continue
            }
        }

        return CommandSummary(
            lineCount: lineCount,
            cubicCount: cubicCount,
            quadCount: quadCount,
            hasClose: hasClose
        )
    }

    private func finalPoint(from commands: [SVGPathCommand]) -> CGPoint? {
        var currentPoint: CGPoint?
        var subpathStart: CGPoint?

        for command in commands {
            switch command {
            case let .moveTo(point):
                currentPoint = point
                subpathStart = point
            case let .lineTo(point):
                currentPoint = point
            case let .cubicCurveTo(_, _, point):
                currentPoint = point
            case let .quadCurveTo(_, point):
                currentPoint = point
            case .close:
                currentPoint = subpathStart
            }
        }

        return currentPoint
    }

    private func assertEqual(_ lhs: CGPoint, _ rhs: FixturePoint, message: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(lhs.x, rhs.xCoordinate, accuracy: 0.001, message, file: file, line: line)
        XCTAssertEqual(lhs.y, rhs.yCoordinate, accuracy: 0.001, message, file: file, line: line)
    }

    private func loadFixtureData(name: String, extension fileExtension: String) throws -> Data {
        let url = try fixtureURL(name: name, extension: fileExtension)
        return try Data(contentsOf: url)
    }

    private func fixtureURL(name: String, extension fileExtension: String, subdirectory: String? = nil) throws -> URL {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: fileExtension,
            subdirectory: subdirectory
        ) else {
            throw FixtureError.missingFixture(name: name, fileExtension: fileExtension, subdirectory: subdirectory)
        }

        return url
    }
}

private struct PathConformanceSuite: Decodable {
    let cases: [PathConformanceCase]
}

private struct PathConformanceCase: Decodable {
    let id: String
    let pathData: String
    let expectedMove: FixturePoint
    let expectedFinalPoint: FixturePoint
    let minimumLineCount: Int
    let minimumCubicCount: Int
    let minimumQuadCount: Int
    let expectsClose: Bool
}

private struct FixturePoint: Decodable {
    let xCoordinate: CGFloat
    let yCoordinate: CGFloat

    private enum CodingKeys: String, CodingKey {
        case xCoordinate = "x"
        case yCoordinate = "y"
    }
}

private struct CommandSummary {
    let lineCount: Int
    let cubicCount: Int
    let quadCount: Int
    let hasClose: Bool
}

private enum FixtureError: LocalizedError {
    case missingFixture(name: String, fileExtension: String, subdirectory: String?)

    var errorDescription: String? {
        switch self {
        case let .missingFixture(name, fileExtension, subdirectory):
            if let subdirectory {
                return "Missing fixture: \(subdirectory)/\(name).\(fileExtension)"
            }
            return "Missing fixture: \(name).\(fileExtension)"
        }
    }
}
