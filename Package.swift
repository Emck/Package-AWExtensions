// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AWExtensions",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "AWExtensions",
            targets: ["AWExtensions"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AWExtensions",
            dependencies: [],
            path: ".",
            publicHeadersPath: "."
        )
    ]
)
