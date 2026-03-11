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
    dependencies: [
        .package(path: "../SplineDomain")
    ],
    targets: [
        .target(
            name: "SplineVectorization",
            dependencies: [
                .product(name: "SplineDomain", package: "SplineDomain")
            ]
        ),
        .testTarget(name: "SplineVectorizationTests", dependencies: ["SplineVectorization"])
    ]
)
