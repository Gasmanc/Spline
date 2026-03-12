import Foundation
import XCTest
@testable import SplineApplication
import SplineDomain
import SplineJobs
import SplineStorage

final class SplineApplicationTests: XCTestCase {
    func testOrchestratorProcessesQueuedJobAndWritesHistory() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let paths = AppPaths(baseDirectory: tempDir)
        let bootstrap = ApplicationBootstrap()
        let orchestrator = bootstrap.makeOrchestrator(paths: paths)

        let inputURL = tempDir.appendingPathComponent("in.png")
        let outputURL = tempDir.appendingPathComponent("out.pdf")
        try makePNG(at: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .pdf,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        _ = try await orchestrator.enqueue(inputURL: inputURL, outputURL: outputURL, intent: intent)
        _ = try await orchestrator.processNextJob()

        let historyStore = ConversionHistoryStore(fileURL: paths.historyFile)
        let history = try await historyStore.load()

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history[0].outcome, .success)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
    }

    private func makePNG(at url: URL) throws {
        let data = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=")
        guard let pngData = data else {
            throw NSError(domain: "TestData", code: 1)
        }
        try pngData.write(to: url, options: .atomic)
    }
}
