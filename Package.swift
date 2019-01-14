// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ElementalController_Linux_Sample",
    dependencies: [
        .package(url: "https://github.com/robreuss/ElementalController.git", from: "0.0.100")
        //.package(url: "https://github.com/robreuss/ElementalController.git", .branch("develop")),
    ],
    targets: [
        .target(
            name: "ElementalController_Linux_Sample",
            dependencies: ["ElementalController"]),
    ]
)
