// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
   
import PackageDescription
   
let package = Package(
  name: "SwiftLambdaRuntimeDemoAustralia",
  platforms: [
      .macOS(.v10_13),
  ],
  products: [
    .executable(name: "SwiftLambdaRuntimeDemoAustralia", targets: ["SwiftLambdaRuntimeDemoAustralia"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from:"0.2.0")),
  ],
  targets: [
    .target(
      name: "SwiftLambdaRuntimeDemoAustralia",
      dependencies: [
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
      ]
    ),
  ]
)
