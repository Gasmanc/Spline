import Foundation
import SplineConversionEngine
import SplineJobs
import SplineStorage

public struct ApplicationBootstrap {
    public init() {}

    public func makeOrchestrator(paths: AppPaths) -> ConversionOrchestrator {
        let queue = ConversionJobQueue(store: FileJobStore(fileURL: paths.jobsFile))
        let converter = FileConversionService()
        let historyStore = ConversionHistoryStore(fileURL: paths.historyFile)
        return ConversionOrchestrator(queue: queue, converter: converter, historyStore: historyStore)
    }
}
