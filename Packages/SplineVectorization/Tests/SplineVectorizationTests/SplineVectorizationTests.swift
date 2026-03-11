import XCTest
@testable import SplineVectorization

final class SplineVectorizationTests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineVectorizationModule.name, "SplineVectorization")
    }
}
