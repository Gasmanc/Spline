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
        .package(path: "../SplineDomain"),
        .package(path: "../SplineVectorization")
    ],
    targets: [
        .target(
            name: "CWebPBridge",
            cSettings: [
                .unsafeFlags(["-I/opt/homebrew/include"], .when(platforms: [.macOS]))
            ],
            linkerSettings: [
                .unsafeFlags(["-L/opt/homebrew/lib", "-lwebp"], .when(platforms: [.macOS]))
            ]
        ),
        .target(
            name: "CAVIFBridge",
            cSettings: [
                .unsafeFlags(["-I/opt/homebrew/include"], .when(platforms: [.macOS]))
            ],
            linkerSettings: [
                .unsafeFlags(["-L/opt/homebrew/lib", "-lavif"], .when(platforms: [.macOS]))
            ]
        ),
        .target(
            name: "SplineConversionEngine",
            dependencies: [
                .product(name: "SplineDomain", package: "SplineDomain"),
                .product(name: "SplineVectorization", package: "SplineVectorization"),
                "CWebPBridge",
                "CAVIFBridge"
            ]
        ),
        .testTarget(
            name: "SplineConversionEngineTests",
            dependencies: ["SplineConversionEngine"]
        )
    ]
)
