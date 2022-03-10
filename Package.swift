// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CookInSwift",
    products: [
        .library(
            name: "CookInSwift",
            targets: ["CookInSwift"]),
        .library(
            name: "ConfigParser",
            targets: ["ConfigParser"]),
        .library(
            name: "i18n",
            targets: ["i18n"]),
    ],
    targets: [
        .target(
            name: "i18n",
            dependencies: []),
        .target(
            name: "ConfigParser",
            dependencies: []),
        .target(
            name: "CookInSwift",
            dependencies: ["ConfigParser", "i18n"]),
        .testTarget(
            name: "CookInSwiftTests",
            dependencies: ["CookInSwift"]),
        .testTarget(
            name: "ConfigParserTests",
            dependencies: ["ConfigParser"])
    ]
)
