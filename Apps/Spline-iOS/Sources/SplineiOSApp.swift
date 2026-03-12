import SwiftUI
import SplineApplication
import SplineStorage
import SplineUI

@main
struct SplineiOSApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

private struct AppRootView: View {
    @State private var statusMessage: String = "Idle"

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                ConversionFormView()
                Text("Status: \(statusMessage)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Spline")
            .task {
                await initializeRuntime()
            }
        }
    }

    private func initializeRuntime() async {
        do {
            _ = try AppPaths.defaultPaths(appName: "Spline")
            statusMessage = "Ready"
        } catch {
            statusMessage = "Initialization failed: \(error.localizedDescription)"
        }
    }
}
