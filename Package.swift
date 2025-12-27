// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v15),           // ✅ iOS 15 minimum
        .macOS(.v15)          // ✅ macOS 15 Sequoia
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NetworkKit",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"]
        )
    ],
    swiftLanguageModes: [.v6]
)
