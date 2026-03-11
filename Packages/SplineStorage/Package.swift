// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineStorage",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineStorage", targets: ["SplineStorage"])
    ],
    targets: [
        .target(name: "SplineStorage"),
        .testTarget(name: "SplineStorageTests", dependencies: ["SplineStorage"])
    ]
)
