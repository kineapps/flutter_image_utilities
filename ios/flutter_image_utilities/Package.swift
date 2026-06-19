// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_image_utilities",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "flutter-image-utilities", targets: ["flutter_image_utilities"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_image_utilities",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
