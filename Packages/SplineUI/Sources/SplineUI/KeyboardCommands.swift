import SwiftUI

public struct ConversionKeyboardCommands: Commands {
    private let onRun: @Sendable () -> Void

    public init(onRun: @escaping @Sendable () -> Void) {
        self.onRun = onRun
    }

    public var body: some Commands {
        CommandMenu("Conversion") {
            Button("Run Conversion") {
                onRun()
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
        }
    }
}
