// swift-tools-version: 5.9
// LyriCanto v1.2.0
import PackageDescription

let package = Package(
    name: "LyriCanto",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "LyriCanto",
            targets: ["LyriCanto"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "LyriCanto",
            dependencies: [],
            path: "LyriCanto/Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LyriCantoTests",
            dependencies: ["LyriCanto"],
            path: "LyriCanto/Tests"
        )
    ]
)
