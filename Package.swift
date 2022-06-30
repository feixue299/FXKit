// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FXSwiftX",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "FXSwiftX",
            targets: ["FXSwiftX"]),
    ],
    targets: [
        .target(
            name: "FXSwiftX",
            path: "FXSwiftX/Classes"),
    ]
)
