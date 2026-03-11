import Combine
import Foundation
import SplineDomain

public final class ConversionFormModel: ObservableObject {
    @Published public var sourceFormat: ImageFormat
    @Published public var targetFormat: ImageFormat
    @Published public var outputColorSpace: OutputColorSpace
    @Published public var traceMode: TraceMode
    @Published public var svgMode: SVGMode

    public init(
        sourceFormat: ImageFormat = .png,
        targetFormat: ImageFormat = .svg,
        outputColorSpace: OutputColorSpace = .sRGB,
        traceMode: TraceMode = .color,
        svgMode: SVGMode = .preserveVectorWhenPossible
    ) {
        self.sourceFormat = sourceFormat
        self.targetFormat = targetFormat
        self.outputColorSpace = outputColorSpace
        self.traceMode = traceMode
        self.svgMode = svgMode
    }

    public func makeIntent(containsAlphaChannel: Bool, containsAnimation: Bool) -> ConversionIntent {
        ConversionIntent(
            sourceFormat: sourceFormat,
            targetFormat: targetFormat,
            containsAlphaChannel: containsAlphaChannel,
            containsAnimation: containsAnimation,
            options: ConversionOptions(
                outputColorSpace: outputColorSpace,
                svgMode: svgMode,
                traceMode: traceMode
            )
        )
    }
}
