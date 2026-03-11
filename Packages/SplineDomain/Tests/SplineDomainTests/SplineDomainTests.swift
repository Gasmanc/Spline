import XCTest
@testable import SplineDomain

final class SplineDomainTests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineDomainModule.name, "SplineDomain")
    }
}
