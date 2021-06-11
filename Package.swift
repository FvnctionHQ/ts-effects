// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TSEffects",
    platforms: [
           .iOS(.v13),
       ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TSEffects",
            targets: ["TSEffects"]),
    ],
    dependencies: [
        .package(
            name: "TSUtils",
            url: "https://github.com/linkov/ts-utils.git",
            .branch("master")
        ),
        .package(url: "https://github.com/nakiostudio/EasyPeasy", .upToNextMajor(from: "1.10.0")),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit/", from: "5.2.0"),
        .package(url: "https://github.com/AudioKit/AudioKit", from: "5.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TSEffects",
            dependencies: ["AudioKit", "TSUtils", "EasyPeasy","SoundpipeAudioKit"]),
        .testTarget(
            name: "TSEffectsTests",
            dependencies: ["TSEffects"]),
    ]
)
