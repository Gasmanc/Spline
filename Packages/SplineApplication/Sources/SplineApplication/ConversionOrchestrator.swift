import Foundation
import SplineConversionEngine
import SplineDomain
import SplineJobs
import SplineStorage

public actor ConversionOrchestrator {
    private let queue: ConversionJobQueue
    private let converter: FileConversionService
    private let historyStore: ConversionHistoryStore

    public init(
        queue: ConversionJobQueue,
        converter: FileConversionService,
        historyStore: ConversionHistoryStore
    ) {
        self.queue = queue
        self.converter = converter
        self.historyStore = historyStore
    }

    @discardableResult
    public func enqueue(inputURL: URL, outputURL: URL, intent: ConversionIntent) async throws -> ConversionJob {
        try await queue.enqueue(inputURL: inputURL, outputURL: outputURL, intent: intent)
    }

    public func processNextJob() async throws -> ConversionJob? {
        guard let job = try await queue.nextRunnableJob() else {
            return nil
        }

        let startedAt = Date()
        do {
            _ = try converter.convert(inputURL: job.inputURL, outputURL: job.outputURL, intent: job.intent)
            try await queue.markCompleted(jobID: job.id)

            let record = ConversionHistoryItem(
                id: job.id,
                inputURL: job.inputURL,
                outputURL: job.outputURL,
                intent: job.intent,
                startedAt: startedAt,
                finishedAt: Date(),
                outcome: .success,
                message: nil
            )
            try await historyStore.append(record)
        } catch {
            try await queue.markFailed(jobID: job.id, message: error.localizedDescription)

            let record = ConversionHistoryItem(
                id: job.id,
                inputURL: job.inputURL,
                outputURL: job.outputURL,
                intent: job.intent,
                startedAt: startedAt,
                finishedAt: Date(),
                outcome: .failure,
                message: error.localizedDescription
            )
            try await historyStore.append(record)
            throw error
        }

        return job
    }
}
