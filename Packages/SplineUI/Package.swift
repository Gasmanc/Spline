// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineUI", targets: ["SplineUI"])
    ],
    targets: [
        .target(name: "SplineUI"),
        .testTarget(name: "SplineUITests", dependencies: ["SplineUI"])
    ]
)
