import SwiftUI
import SplineUI

@main
struct SplineiPadOSApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                List {
                    Label("Convert", systemImage: "arrow.triangle.2.circlepath")
                }
                .navigationTitle("Spline")
            } detail: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ConversionFormView()
                        Divider()
                        FileConversionFlowView()
                    }
                    .padding()
                }
                .navigationTitle("Image Conversion")
            }
        }
        .commands {
            ConversionKeyboardCommands {
                NotificationCenter.default.post(name: .runConversionCommandPad, object: nil)
            }
        }
    }
}

private extension Notification.Name {
    static let runConversionCommandPad = Notification.Name("runConversionCommandPad")
}
