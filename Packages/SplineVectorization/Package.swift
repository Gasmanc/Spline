// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SplineVectorization",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SplineVectorization", targets: ["SplineVectorization"])
    ],
    targets: [
        .target(name: "SplineVectorization"),
        .testTarget(name: "SplineVectorizationTests", dependencies: ["SplineVectorization"])
    ]
)
