import SwiftUI
import SplineDomain

public struct ConversionFormView: View {
    @StateObject private var model: ConversionFormModel

    public init(model: ConversionFormModel = ConversionFormModel()) {
        self._model = StateObject(wrappedValue: model)
    }

    public var body: some View {
        Form {
            Picker("Source Format", selection: $model.sourceFormat) {
                ForEach(ImageFormat.allCases, id: \.self) { format in
                    Text(format.rawValue.uppercased()).tag(format)
                }
            }

            Picker("Target Format", selection: $model.targetFormat) {
                ForEach(ImageFormat.allCases, id: \.self) { format in
                    Text(format.rawValue.uppercased()).tag(format)
                }
            }

            Picker("Color Space", selection: $model.outputColorSpace) {
                Text("sRGB").tag(OutputColorSpace.sRGB)
                Text("Display P3").tag(OutputColorSpace.displayP3)
                Text("CMYK").tag(OutputColorSpace.cmyk)
            }

            if model.targetFormat == .svg {
                Picker("SVG Mode", selection: $model.svgMode) {
                    Text("Preserve Vector When Possible").tag(SVGMode.preserveVectorWhenPossible)
                    Text("Force Raster Trace").tag(SVGMode.forceRasterTrace)
                }

                Picker("Trace Mode", selection: $model.traceMode) {
                    Text("Color").tag(TraceMode.color)
                    Text("Black and White").tag(TraceMode.blackAndWhite)
                }
            }
        }
    }
}
