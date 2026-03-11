// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineConversionEngine",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineConversionEngine", targets: ["SplineConversionEngine"])
    ],
    targets: [
        .target(name: "SplineConversionEngine"),
        .testTarget(name: "SplineConversionEngineTests", dependencies: ["SplineConversionEngine"])
    ]
)
