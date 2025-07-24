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
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "medi",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ],
            resources: [
                .copy("FreeMindfulness10MinuteBreathing (1).mp3"),
                .copy("FreeMindfulness3MinuteBreathing (1).mp3"),
                .copy("LifeHappens5MinuteBreathing (1).mp3"),
                .copy("PadraigTenMinuteMindfulnessOfBreathing (1).mp3"),
                .copy("StillMind6MinuteBreathAwareness (1).mp3"),
                .copy("MARC5MinuteBreathing (1).mp3")
            ]),
    ]
) 