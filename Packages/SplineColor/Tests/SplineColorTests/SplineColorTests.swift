import XCTest
@testable import SplineColor

final class SplineColorTests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineColorModule.name, "SplineColor")
    }
}
