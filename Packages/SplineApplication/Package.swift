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
    dependencies: [
        .package(path: "../SplineDomain"),
        .package(path: "../SplineConversionEngine"),
        .package(path: "../SplineJobs"),
        .package(path: "../SplineStorage")
    ],
    targets: [
        .target(
            name: "SplineApplication",
            dependencies: [
                .product(name: "SplineDomain", package: "SplineDomain"),
                .product(name: "SplineConversionEngine", package: "SplineConversionEngine"),
                .product(name: "SplineJobs", package: "SplineJobs"),
                .product(name: "SplineStorage", package: "SplineStorage")
            ]
        ),
        .testTarget(name: "SplineApplicationTests", dependencies: ["SplineApplication"])
    ]
)
