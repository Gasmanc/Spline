import XCTest
@testable import SplineConversionEngine

final class SplineConversionEngineTests: XCTestCase {
    func testModuleName() throws {
        XCTAssertEqual(SplineConversionEngineModule.name, "SplineConversionEngine")
    }
}
