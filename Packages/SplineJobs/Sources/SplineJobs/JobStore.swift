import Foundation

public protocol JobStore: Sendable {
    func load() async throws -> [ConversionJob]
    func save(_ jobs: [ConversionJob]) async throws
}

public actor FileJobStore: JobStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.outputFormatting = [.sortedKeys]
    }

    public func load() async throws -> [ConversionJob] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([ConversionJob].self, from: data)
    }

    public func save(_ jobs: [ConversionJob]) async throws {
        let data = try encoder.encode(jobs)
        try data.write(to: fileURL, options: .atomic)
    }
}
