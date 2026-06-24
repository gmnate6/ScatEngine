// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScatEngine",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ScatEngine",
            targets: ["ScatEngine"]
        ),
        .executable(
            name: "scat",
            targets: ["ScatCLI"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ScatEngine"
        ),
        .executableTarget(
            name: "ScatCLI",
            dependencies: ["ScatEngine"]
        ),
        .testTarget(
            name: "ScatEngineTests",
            dependencies: ["ScatEngine"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
