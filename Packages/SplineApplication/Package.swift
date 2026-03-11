// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineApplication",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineApplication", targets: ["SplineApplication"])
    ],
    targets: [
        .target(name: "SplineApplication"),
        .testTarget(name: "SplineApplicationTests", dependencies: ["SplineApplication"])
    ]
)
