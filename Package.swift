// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AsyncView",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "AsyncView", targets: ["AsyncView"]),
    ],
    targets: [
        .target(name: "AsyncView"),
        .testTarget(name: "AsyncViewTests", dependencies: ["AsyncView"]),
    ]
)
