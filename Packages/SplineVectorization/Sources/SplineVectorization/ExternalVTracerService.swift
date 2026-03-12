import Foundation
import SplineDomain

public struct ExternalVTracerService: Sendable {
    public init() {}

    public func trace(
        inputURL: URL,
        outputURL: URL,
        mode: TraceMode,
        controls: TraceControls
    ) -> Bool {
        #if os(macOS)
        guard let executable = resolveExecutablePath() else {
            return false
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments(
            inputURL: inputURL,
            outputURL: outputURL,
            mode: mode,
            controls: controls
        )

        let errorPipe = Pipe()
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
        #else
        _ = inputURL
        _ = outputURL
        _ = mode
        _ = controls
        return false
        #endif
    }

    #if os(macOS)
    private func resolveExecutablePath() -> String? {
        let environmentPath = ProcessInfo.processInfo.environment["PATH"] ?? ""
        for directory in environmentPath.split(separator: ":") {
            let candidate = URL(fileURLWithPath: String(directory)).appendingPathComponent("vtracer")
            if FileManager.default.isExecutableFile(atPath: candidate.path) {
                return candidate.path
            }
        }

        let cargoPath = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".cargo/bin/vtracer").path
        if FileManager.default.isExecutableFile(atPath: cargoPath) {
            return cargoPath
        }

        return nil
    }

    private func arguments(
        inputURL: URL,
        outputURL: URL,
        mode: TraceMode,
        controls: TraceControls
    ) -> [String] {
        let colorMode = mode == .color ? "color" : "bw"
        let precision = max(3, min(8, Int((1 - controls.pathSimplification) * 8)))
        let speckle = max(1, Int((controls.despeckle * 20).rounded()))
        let corner = max(20, min(180, Int((1 - controls.cornerSmoothing) * 180)))

        return [
            "--input", inputURL.path,
            "--output", outputURL.path,
            "--colormode", colorMode,
            "--color_precision", "\(precision)",
            "--filter_speckle", "\(speckle)",
            "--corner_threshold", "\(corner)",
            "--mode", "spline"
        ]
    }
    #endif
}
