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
    dependencies: [
        .package(path: "../SplineDomain")
    ],
    targets: [
        .target(
            name: "SplineConversionEngine",
            dependencies: [
                .product(name: "SplineDomain", package: "SplineDomain")
            ]
        ),
        .testTarget(
            name: "SplineConversionEngineTests",
            dependencies: ["SplineConversionEngine"]
        )
    ]
)
