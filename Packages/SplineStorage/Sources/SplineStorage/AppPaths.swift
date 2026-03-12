import Foundation

public struct AppPaths: Sendable {
    public let baseDirectory: URL

    public init(baseDirectory: URL) {
        self.baseDirectory = baseDirectory
    }

    public static func defaultPaths(appName: String = "Spline") throws -> AppPaths {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let base = appSupport.appendingPathComponent(appName, isDirectory: true)
        try fileManager.createDirectory(at: base, withIntermediateDirectories: true)
        return AppPaths(baseDirectory: base)
    }

    public var jobsFile: URL {
        baseDirectory.appendingPathComponent("jobs.json")
    }

    public var historyFile: URL {
        baseDirectory.appendingPathComponent("history.json")
    }

    public var temporaryDirectory: URL {
        baseDirectory.appendingPathComponent("tmp", isDirectory: true)
    }
}
