import AWSLambdaRuntime
import Foundation
import AWSLambdaEvents
import NIO
import Logging
import Rekognition

struct Output: Codable {
    let message: String
}

let bucket = getEnvVariable(name: "BUCKET")
let tableName = getEnvVariable(name: "TABLE_NAME")
let accessKey = getEnvVariable(name: "AWS_ACCESS_KEY_ID")
let secret = getEnvVariable(name: "AWS_SECRET_ACCESS_KEY")
let s3 = s3Sdk(accessKeyId: accessKey, secretAccessKey: secret, region: .uswest2)
let rekognition = Rekognition(accessKeyId: accessKey, secretAccessKey: secret, region: .uswest2)
let dynamoDb = dynamo(accessKeyId: accessKey, secretAccessKey: secret, region: .uswest2)
Lambda.run { (context, messages: DynamoDB.Event, callback: @escaping (Result<Output, Error>) -> Void) in
    let logger = context.logger
    logger.info("Records: \(messages.records)")
    guard let bucket = bucket, let tableName = tableName else {
        callback(.failure(LambdaError.bucketNameOrTableNameEmpty))
    }
    for message in messages.records {
        
        guard var event = message.change.newImage else {
            callback(.failure(LambdaError.newDynamoEventEmpty))
            return
        }
        guard case let .string(key) = event["key"] else {
            callback(.failure(LambdaError.newDynamoEventEmpty))
            return
        }
        
        //call to s3 to get the object by key
        let getObjectRequest = s3Sdk.GetObjectRequest(bucket: bucket, key: key)
        
        s3.getObject(getObjectRequest)
            .flatMap { response -> EventLoopFuture<Rekognition.DetectLabelsResponse> in
               
                guard let body = response.body else {
                    logger.info("object was empty")
                    callback(.failure(LambdaError.objectWasEmpty))
                    return context.eventLoop.makeFailedFuture(LambdaError.objectWasEmpty)
                }
                logger.info("we did get the object successfully")
                //call rekognition for labels to detect images with Waterfalls
                let image = Rekognition.Image(bytes: body)
                let detectLabelsRequest = Rekognition.DetectLabelsRequest(image: image)
                return rekognition.detectLabels(detectLabelsRequest)
             
                
        }.flatMap { response -> EventLoopFuture<dynamo.PutItemOutput> in
            var containsWaterfalls = false
            if let labels = response.labels {
                for label in labels where label.name == "Photography" {
                    logger.info("Label: \(label.name!)")
                    containsWaterfalls.toggle()
                }
            }
            event["isFeatured"] = .boolean(containsWaterfalls)
            let newEvent = event.mapValues { (eventValue) -> dynamo.AttributeValue in
                switch eventValue {
                case .string(let value):
                    return dynamo.AttributeValue(s: value)
                case .boolean(let value):
                    return dynamo.AttributeValue(bool: value)
                case .binary(let value):
                    return dynamo.AttributeValue(b: Data(bytes: value, count: value.count))
                case .binarySet(let value):
                    return dynamo.AttributeValue(bs: [Data(bytes: value, count: value.count)])
                case .stringSet(let value):
                    return dynamo.AttributeValue(ss: value)
                case .null:
                    return dynamo.AttributeValue(null: nil)
                case .number(let value):
                    return dynamo.AttributeValue(n: value)
                case .numberSet(let value):
                    return dynamo.AttributeValue(ns: value)
                default: break
                }
                return dynamo.AttributeValue(null: nil)
            }
            
            //save to dynamodb
            let putObjectRequest = dynamo.PutItemInput(item: newEvent, tableName: tableName)
            return dynamoDb.putItem(putObjectRequest)
            
        }.whenComplete { result in
            switch result {
            case .success:
                logger.info("the call to put item back in dynamo succeeded")
               
                callback(.success(Output(message: "the call to put item back in dynamo succeeded")))
            case .failure(let error):
                logger.error("The call to dynamo failed")
                
                callback(.failure(error))
            }
        }
        
    }
}

enum LambdaError: Error {
    
    case objectWasEmpty
    case newDynamoEventEmpty
    case failedToPutObject
    case bucketNameOrTableNameEmpty
}

func getEnvVariable(name: String) -> String? {
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    return nil
}



