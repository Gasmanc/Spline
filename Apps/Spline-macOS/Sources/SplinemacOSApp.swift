import SwiftUI
import SplineUI

@main
struct SplinemacOSApp: App {
    var body: some Scene {
        WindowGroup {
            MacRootView()
        }
        .commands {
            ConversionKeyboardCommands {
                NotificationCenter.default.post(name: .runConversionCommand, object: nil)
            }
        }
    }
}

private struct MacRootView: View {
    @State private var triggerCount: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ConversionFormView()
            Text("Run command count: \(triggerCount)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(minWidth: 720, minHeight: 520)
        .onReceive(NotificationCenter.default.publisher(for: .runConversionCommand)) { _ in
            triggerCount += 1
        }
    }
}

private extension Notification.Name {
    static let runConversionCommand = Notification.Name("runConversionCommand")
}
