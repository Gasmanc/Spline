import Foundation

public enum ImageFormat: String, CaseIterable, Codable, Sendable {
    case jpeg
    case bmp
    case heic
    case webp
    case gif
    case raw
    case svg
    case tiff
    case png
    case avif
    case hdr
    case eps
    case pdf

    public var isVector: Bool {
        switch self {
        case .svg, .eps, .pdf:
            return true
        case .jpeg, .bmp, .heic, .webp, .gif, .raw, .tiff, .png, .avif, .hdr:
            return false
        }
    }
}
