import AWSLambdaRuntime
import Foundation
import AWSLambdaEvents
import NIO
import Logging

struct Output: Codable {
    let message: String
}

let bucket = "mythical-mysfits-bucket-nicki"
let accessKey = getEnvVariable(name: "AWS_ACCESS_KEY_ID")
let secret = getEnvVariable(name: "AWS_SECRET_ACCESS_KEY")
let logger = Logger(label: "lambdaLogger")
logger.info("AccessKey:\(accessKey ?? "no access key found")")
logger.info("Secret: \(secret ?? "no secret found")")
let s3 = s3Sdk(accessKeyId: accessKey, secretAccessKey: secret, region: .uswest2)

Lambda.run { (context, messages: S3.Event, callback: @escaping (Result<Output, Error>) -> Void) in
    logger.info("Records: \(messages.records)")
    for message in messages.records {
        let key = message.s3.object.key
        //call to s3 to get the object by key
        let data = getObject(key: key)
       
        data.whenSuccess { response in
            if let body = response.body {
                
                logger.info("item:\(body)")
                putObject(key: key + "/resized", bucket: bucket, image: body).whenSuccess { response in
                    logger.info("the call to put object succeeded")
                    callback(.success(Output(message: "Putting resized object back succeeded")))
                }
            } else {
                logger.info("this should never happen")
                
                callback(.failure(LambdaError.objectWasEmpty))
            }
        }

        data.whenFailure { response in
            logger.error("The call to get object failed")
            callback(.failure(response))
        }
        //resize image
        
        //drop back in s3
        
        
    }
    
}

enum LambdaError: Error {
    case objectWasEmpty
}

func getEnvVariable(name: String) -> String? {
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    return nil
}
func getEnvironmentVar(_ name: String) -> String? {
    guard let rawValue = getenv(name) else { return nil }
    return String(utf8String: rawValue)
}

func getObject(key: String) -> EventLoopFuture<s3Sdk.GetObjectOutput> {
    let getObjectRequest = s3Sdk.GetObjectRequest(bucket: bucket, key: key)
    
    return s3.getObject(getObjectRequest)
}

func putObject(key: String, bucket: String, image: Data) -> EventLoopFuture<s3Sdk.PutObjectOutput> {
    let putObjectRequest = s3Sdk.PutObjectRequest(acl: .publicRead, body: image, bucket: bucket, contentLength: Int64(image.count), key: key)
    return s3.putObject(putObjectRequest)
}


