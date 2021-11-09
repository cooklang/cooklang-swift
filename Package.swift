// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CookInSwift",
    products: [
        .library(
            name: "CookInSwift",
            targets: ["CookInSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6")
    ],
    targets: [
        .target(
            name: "CookInSwift",
            dependencies: []),
        .testTarget(
            name: "CookInSwiftTests",
            dependencies: ["CookInSwift", "Yams"]
        ),
    ]
)
