// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineDomain",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineDomain", targets: ["SplineDomain"])
    ],
    targets: [
        .target(name: "SplineDomain"),
        .testTarget(name: "SplineDomainTests", dependencies: ["SplineDomain"])
    ]
)
