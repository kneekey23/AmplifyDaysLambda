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
    .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.7.0"),
  ],
  targets: [
    .target(
      name: "SwiftLambdaRuntimeDemoAustralia",
      dependencies: [
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
        .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
        .product(name: "S3", package: "AWSSDKSwift"),
        .product(name: "Rekognition", package: "AWSSDKSwift"),
        .product(name: "DynamoDB", package: "AWSSDKSwift")
      ]
    ),
  ]
)
