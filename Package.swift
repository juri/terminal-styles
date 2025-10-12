// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "terminal-styles",
    platforms: [.macOS(.v15)],
    products: [
        .executable(
            name: "run-terminal-styles",
            targets: ["RunTerminalStyles"],
        ),
        .library(
            name: "TerminalStyles",
            targets: ["TerminalStyles"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/juri/terminal-ansi", from: "0.1.5")
    ],
    targets: [
        .executableTarget(
            name: "RunTerminalStyles",
            dependencies: [
                "TerminalStyles",
                .product(name: "TerminalANSI", package: "terminal-ansi"),
            ]
        ),
        .target(
            name: "TerminalStyles",
            dependencies: [
                .product(name: "TerminalANSI", package: "terminal-ansi")
            ],
        ),
        .testTarget(
            name: "TerminalStylesTests",
            dependencies: ["TerminalStyles"]
        ),
    ]
)
