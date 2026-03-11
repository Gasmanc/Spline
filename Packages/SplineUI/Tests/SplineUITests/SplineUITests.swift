import XCTest
@testable import SplineUI

final class SplineUITests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineUIModule.name, "SplineUI")
    }
}
