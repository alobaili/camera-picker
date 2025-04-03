// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CameraPicker",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(name: "CameraPicker", targets: ["CameraPicker"])
    ],
    targets: [
        .target(name: "CameraPicker", dependencies: []),
        .testTarget(name: "CameraPickerTests", dependencies: ["CameraPicker"])
    ]
)
