import Foundation
import SplineDomain

public actor ConversionJobQueue {
    private var jobs: [ConversionJob]
    private let store: JobStore

    public init(store: JobStore, preload: [ConversionJob] = []) {
        self.store = store
        self.jobs = preload
    }

    public func restore() async throws {
        jobs = try await store.load()
    }

    @discardableResult
    public func enqueue(inputURL: URL, outputURL: URL, intent: ConversionIntent) async throws -> ConversionJob {
        var job = ConversionJob(inputURL: inputURL, outputURL: outputURL, intent: intent)
        job.updatedAt = Date()
        jobs.append(job)
        try await persist()
        return job
    }

    public func listJobs() async -> [ConversionJob] {
        jobs.sorted(by: { $0.createdAt < $1.createdAt })
    }

    public func nextRunnableJob() async throws -> ConversionJob? {
        guard let index = jobs.firstIndex(where: { $0.state == .queued || $0.state == .paused }) else {
            return nil
        }

        jobs[index].state = .running
        jobs[index].updatedAt = Date()
        try await persist()
        return jobs[index]
    }

    public func updateProgress(jobID: UUID, progress: Double) async throws {
        guard let index = jobs.firstIndex(where: { $0.id == jobID }) else {
            return
        }

        jobs[index].progress = max(0, min(1, progress))
        jobs[index].updatedAt = Date()
        try await persist()
    }

    public func markCompleted(jobID: UUID) async throws {
        try await mutate(jobID: jobID) {
            $0.state = .completed
            $0.progress = 1
            $0.failureMessage = nil
        }
    }

    public func markFailed(jobID: UUID, message: String) async throws {
        try await mutate(jobID: jobID) {
            $0.state = .failed
            $0.failureMessage = message
        }
    }

    public func pause(jobID: UUID) async throws {
        try await mutate(jobID: jobID) {
            if $0.state == .running || $0.state == .queued {
                $0.state = .paused
            }
        }
    }

    public func cancel(jobID: UUID) async throws {
        try await mutate(jobID: jobID) {
            $0.state = .canceled
        }
    }

    private func mutate(jobID: UUID, operation: (inout ConversionJob) -> Void) async throws {
        guard let index = jobs.firstIndex(where: { $0.id == jobID }) else {
            return
        }

        operation(&jobs[index])
        jobs[index].updatedAt = Date()
        try await persist()
    }

    private func persist() async throws {
        try await store.save(jobs)
    }
}
