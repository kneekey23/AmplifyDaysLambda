import AWSLambdaRuntime

struct Input: Codable {
    let audienceName: String
}

struct Output: Codable {
    let message: String
}

Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Error>) -> Void) in
    callback(.success(Output(message: "Hi \(input.audienceName)! Welcome to my lambda demo!")))
}

