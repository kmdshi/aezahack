// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Extension",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Extension",
            type: .static,
            targets: ["Extension"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Extension",
            dependencies: []),
        .testTarget(
            name: "ExtensionTests",
            dependencies: ["Extension"]),
    ]
)