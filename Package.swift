// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOklchSimd",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "SwiftOklchSimd",
            targets: ["SwiftOklchSimd"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftOklchSimd"
        ),
        .testTarget(
            name: "SwiftOklchSimdTests",
            dependencies: ["SwiftOklchSimd"]
        ),
    ]
)

