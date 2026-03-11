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
    targets: [
        .target(name: "SplineJobs"),
        .testTarget(name: "SplineJobsTests", dependencies: ["SplineJobs"])
    ]
)
