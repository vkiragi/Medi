// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "medi",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "medi",
            targets: ["medi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "medi",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
    ]
) 