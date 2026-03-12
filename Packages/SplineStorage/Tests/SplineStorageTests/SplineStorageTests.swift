import Foundation
import XCTest
@testable import SplineStorage
import SplineDomain

final class SplineStorageTests: XCTestCase {
    func testHistoryAppendAndLoad() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let store = ConversionHistoryStore(fileURL: tempDir.appendingPathComponent("history.json"))

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .jpeg,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        let item = ConversionHistoryItem(
            inputURL: URL(fileURLWithPath: "/tmp/input.png"),
            outputURL: URL(fileURLWithPath: "/tmp/output.jpg"),
            intent: intent,
            startedAt: Date(),
            finishedAt: Date(),
            outcome: .success,
            message: nil
        )

        try await store.append(item)
        let loaded = try await store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].intent.targetFormat, .jpeg)
    }
}
