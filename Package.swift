// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PaginatedList",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PaginatedList",
            targets: ["PaginatedList"]
        )
    ],
    targets: [
        .target(
            name: "PaginatedList"
        ),
        .testTarget(
            name: "PaginatedListTests",
            dependencies: ["PaginatedList"]
        )
    ]
)
