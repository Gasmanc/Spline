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
    dependencies: [
        .package(path: "../SplineDomain")
    ],
    targets: [
        .target(
            name: "SplineStorage",
            dependencies: [
                .product(name: "SplineDomain", package: "SplineDomain")
            ]
        ),
        .testTarget(name: "SplineStorageTests", dependencies: ["SplineStorage"])
    ]
)
