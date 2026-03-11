import XCTest
@testable import SplineStorage

final class SplineStorageTests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineStorageModule.name, "SplineStorage")
    }
}
