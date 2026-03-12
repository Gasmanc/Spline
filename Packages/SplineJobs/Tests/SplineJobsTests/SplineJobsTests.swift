import Foundation
import XCTest
@testable import SplineJobs
import SplineDomain

final class SplineJobsTests: XCTestCase {
    func testQueueLifecycleAndPersistence() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let storeURL = tempDir.appendingPathComponent("jobs.json")

        let store = FileJobStore(fileURL: storeURL)
        let queue = ConversionJobQueue(store: store)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .jpeg,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        let created = try await queue.enqueue(
            inputURL: URL(fileURLWithPath: "/tmp/in.png"),
            outputURL: URL(fileURLWithPath: "/tmp/out.jpg"),
            intent: intent
        )

        let running = try await queue.nextRunnableJob()
        XCTAssertEqual(running?.id, created.id)
        XCTAssertEqual(running?.state, .running)

        try await queue.updateProgress(jobID: created.id, progress: 0.75)
        try await queue.markCompleted(jobID: created.id)

        let restoredQueue = ConversionJobQueue(store: store)
        try await restoredQueue.restore()
        let all = await restoredQueue.listJobs()

        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all[0].state, .completed)
        XCTAssertEqual(all[0].progress, 1)
        XCTAssertNil(all[0].failureMessage)
    }
}
