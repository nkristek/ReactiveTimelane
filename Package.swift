// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "ReactiveTimelane",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "ReactiveTimelane", targets: ["ReactiveTimelane"]),
    ],
    dependencies: [
        .package(url: "https://github.com/icanzilb/TimelaneCore", from: "1.0.9"),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.3.0")
    ],
    targets: [
        .target( name: "ReactiveTimelane", dependencies: ["ReactiveSwift", "TimelaneCore"]),
        .testTarget( name: "ReactiveTimelaneTests", dependencies: ["ReactiveTimelane", "ReactiveSwift"]),
    ],
    swiftLanguageVersions: [.v5]
)
