// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CursorPointer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "CursorPointer", targets: ["CursorPointer"])
    ],
    targets: [
        .executableTarget(
            name: "CursorPointer",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
