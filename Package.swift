// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "medi",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "medi",
            targets: ["medi"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "medi",
            dependencies: []),
        .testTarget(
            name: "mediTests",
            dependencies: ["medi"]),
    ]
) 