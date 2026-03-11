// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineColor",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineColor", targets: ["SplineColor"])
    ],
    targets: [
        .target(name: "SplineColor"),
        .testTarget(name: "SplineColorTests", dependencies: ["SplineColor"])
    ]
)
