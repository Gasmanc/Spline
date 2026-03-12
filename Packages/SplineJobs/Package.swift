// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineJobs",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineJobs", targets: ["SplineJobs"])
    ],
    dependencies: [
        .package(path: "../SplineDomain")
    ],
    targets: [
        .target(
            name: "SplineJobs",
            dependencies: [
                .product(name: "SplineDomain", package: "SplineDomain")
            ]
        ),
        .testTarget(name: "SplineJobsTests", dependencies: ["SplineJobs"])
    ]
)
