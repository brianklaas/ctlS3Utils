/*
CTL S3 Request Utilities

This component is a utility for creating signed requests for objects in S3.

Author: Brian Klaas (bklaas@jhu.edu)
Created: August 1, 2013
Major refactor: June 19, 2019
Copyright 2013, 2019 Brian Klaas

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

component output="false" hint="A utility for creating signed requests for objects in S3" {

	/**
	*	@description Component initialization
	*	@requiredArguments
	*		- awsAccessKey = the access key value of an Amazon IAM account that has permissions to read the requested S3 bucket.
	*		- awsSecretKey = the secret key value of an Amazon IAM account that has permissions to read the requested S3 bucket.
	*/
	public any function init(required string awsAccessKey, required string awsSecretKey) {
		var awsCredentials = CreateObject('java','com.amazonaws.auth.BasicAWSCredentials').init(arguments.awsAccessKey, arguments.awsSecretKey);
		var awsStaticCredentialsProvider = CreateObject('java','com.amazonaws.auth.AWSStaticCredentialsProvider').init(awsCredentials);
        	variables.s3 = CreateObject('java', 'com.amazonaws.services.s3.AmazonS3ClientBuilder').standard().withCredentials(awsStaticCredentialsProvider).withRegion("us-east-1").build();
		return this;
	}

	/**
	*	@description Creates a signed URL to the specified object in S3. Optionally takes expiration date, content disposition, and content type values.
	*	@requiredArguments
	*		- s3BucketName = the name of the S3 bucket where the object you are requesting resides.
	*		- objectKey = the path to and file name of the file in the specified bucket.
	*	@optionalArguments
	*		- expiresOnDate = the date/time on which this signed URL expires. Defaults to one hour from Now().
	*		- fileNameToUse = string value of the alternate file name to serve the file as.
	*		- isAttachment = boolean indicating if the file should be served as an attachment (download). Otherwise the file is served inline.
	* 		- mimeType = string value representing the MIME type of the content
	*/
	public string function createSignedURL(required string s3BucketName, required string objectKey, date expiresOnDate = dateAdd("h",1,Now()), string fileNameToUse = "", boolean isAttachment = false, string mimeType = "") {
		var contentDisposition = (arguments.isAttachment) ? "attachment" : "inline";
		if (len(trim(arguments.fileNameToUse))) {
			contentDisposition &= "; filename=" & trim(arguments.fileNameToUse);
		}
		var responseHeaderOverrides = CreateObject('java', 'com.amazonaws.services.s3.model.ResponseHeaderOverrides')
                .withContentDisposition(contentDisposition);
		if (len(trim(arguments.mimeType))) {
			responseHeaderOverrides.setContentType(trim(arguments.mimeType));
		}
		var generatePresignedUrlRequest = CreateObject('java', 'com.amazonaws.services.s3.model.GeneratePresignedUrlRequest')
                .init(trim(arguments.s3BucketName), trim(arguments.objectKey))
                .withExpiration(arguments.expiresOnDate)
                .withResponseHeaders(responseHeaderOverrides);
		return variables.s3.generatePresignedUrl(generatePresignedUrlRequest).toString();
	}

}
