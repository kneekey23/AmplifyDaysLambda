# AmplifyDaysLambda

This package is a demo of setting up a Swift Lambda to use the Swift Lambda Runtime. 
Commands to deploy this Lambda to your own account are:
1. Set up the docker image by running
```
docker build -t swift-lambda .
```
2. Build the swift package inside the docker container by running it
```
docker run \
     --rm \
     --volume "$(pwd)/:/src" \
     --workdir "/src/" \
     swift-lambda \
     swift build --product AmplifyDaysLambda -c release
```
3. Package the Lambda inside the docker container by running it again and calling the script this time
```
docker run \
     --rm \
     --volume "$(pwd)/:/src" \
     --workdir "/src/" \
     swift-lambda \
     scripts/package.sh AmplifyDaysLambda
```
4. Create a lambda with a custom runtime of "Provide your own bootstrap" and upload the zip that was created in step 3 which is located at `pathToThisRepo/.build/lambda/AmplifyDaysLambda/lambda.zip`
     
More info [here](https://swift.org/blog/aws-lambda-runtime/). 
Full Demo is [here](https://www.twitch.tv/videos/661560410?t=04h34m51s)
