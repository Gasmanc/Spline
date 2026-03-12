import SwiftUI
import UniformTypeIdentifiers
import SplineConversionEngine
import SplineDomain

struct FileConversionFlowView: View {
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var selectedInputURL: URL?
    @State private var targetFormat: ImageFormat = .svg
    @State private var exportDocument: BinaryFileDocument?
    @State private var exportContentType: UTType = .svg
    @State private var exportFilename: String = "output"
    @State private var status: String = "Select an input file"

    private let converter = FileConversionService()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Choose Input") {
                    isImporting = true
                }

                if let selectedInputURL {
                    Text(selectedInputURL.lastPathComponent)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Picker("Target Format", selection: $targetFormat) {
                ForEach(ImageFormat.allCases, id: \.self) { format in
                    Text(format.rawValue.uppercased()).tag(format)
                }
            }

            Button("Convert") {
                Task {
                    await runConversion()
                }
            }
            .disabled(selectedInputURL == nil)

            Text(status)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                selectedInputURL = urls.first
                status = "Input selected"
            case let .failure(error):
                status = "Import failed: \(error.localizedDescription)"
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: exportContentType,
            defaultFilename: exportFilename
        ) { result in
            switch result {
            case .success:
                status = "Export complete"
            case let .failure(error):
                status = "Export failed: \(error.localizedDescription)"
            }
        }
    }

    private func runConversion() async {
        guard let inputURL = selectedInputURL else {
            status = "No input file selected"
            return
        }

        let sourceFormat = detectFormat(from: inputURL)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(targetFormat.rawValue)

        let intent = ConversionIntent(
            sourceFormat: sourceFormat,
            targetFormat: targetFormat,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        do {
            _ = try converter.convert(inputURL: inputURL, outputURL: tempURL, intent: intent)
            let data = try Data(contentsOf: tempURL)
            exportDocument = BinaryFileDocument(data: data)
            exportContentType = contentType(for: targetFormat)
            exportFilename = "converted.\(targetFormat.rawValue)"
            isExporting = true
            status = "Conversion complete"
        } catch {
            status = "Conversion failed: \(error.localizedDescription)"
        }
    }

    private func detectFormat(from url: URL) -> ImageFormat {
        let extensionMap: [String: ImageFormat] = [
            "jpg": .jpeg,
            "jpeg": .jpeg,
            "bmp": .bmp,
            "heic": .heic,
            "heif": .heic,
            "webp": .webp,
            "gif": .gif,
            "raw": .raw,
            "dng": .raw,
            "cr2": .raw,
            "nef": .raw,
            "svg": .svg,
            "tif": .tiff,
            "tiff": .tiff,
            "png": .png,
            "avif": .avif,
            "hdr": .hdr,
            "eps": .eps,
            "pdf": .pdf
        ]

        return extensionMap[url.pathExtension.lowercased()] ?? .png
    }

    private func contentType(for format: ImageFormat) -> UTType {
        let typeMap: [ImageFormat: UTType] = [
            .jpeg: .jpeg,
            .bmp: .bmp,
            .heic: .heic,
            .webp: .webP,
            .gif: .gif,
            .raw: .data,
            .svg: .svg,
            .tiff: .tiff,
            .png: .png,
            .avif: .data,
            .hdr: .data,
            .eps: .data,
            .pdf: .pdf
        ]

        return typeMap[format] ?? .data
    }
}

private struct BinaryFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.data] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let fileData = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = fileData
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
