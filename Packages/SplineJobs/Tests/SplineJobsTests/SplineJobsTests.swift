import XCTest
@testable import SplineJobs

final class SplineJobsTests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineJobsModule.name, "SplineJobs")
    }
}
