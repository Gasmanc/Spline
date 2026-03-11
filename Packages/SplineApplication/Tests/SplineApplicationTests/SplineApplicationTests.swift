import XCTest
@testable import SplineApplication

final class SplineApplicationTests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineApplicationModule.name, "SplineApplication")
    }
}
