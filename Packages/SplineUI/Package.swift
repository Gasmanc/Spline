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
    dependencies: [
        .package(path: "../SplineDomain"),
        .package(path: "../SplineJobs")
    ],
    targets: [
        .target(
            name: "SplineUI",
            dependencies: [
                .product(name: "SplineDomain", package: "SplineDomain"),
                .product(name: "SplineJobs", package: "SplineJobs")
            ]
        ),
        .testTarget(name: "SplineUITests", dependencies: ["SplineUI"])
    ]
)
