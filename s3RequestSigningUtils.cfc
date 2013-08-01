/*
CTL S3 Request Utilities

This component is a utility for creating signed requests for objects in S3.

Author: Brian Klaas (bklaas@jhsph.edu)
Created: August 1, 2013
Copyright 2013, Brian Klaas

Ideas pulled from:
	http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGET.html
	http://amazons3.riaforge.org/
	http://www.bennadel.com/blog/2502-Uploading-Files-To-Amazon-S3-Using-Plupload-And-ColdFusion.htm

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
		variables.awsAccessKey = arguments.awsAccessKey;
		variables.awsSecretKey = arguments.awsSecretKey;
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
		var fullURLWithSignature = "";
		var signature = "";
		var epochTime = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), arguments.expiresOnDate);
		var contentDisposition = (arguments.isAttachment) ? "response-content-disposition=attachment" : "response-content-disposition=inline";
		// We have to create both the canonical AWS GET request string to encode as well as the URL to return
		var awsGetRequest = "GET\n\n\n#epochTime#\n/#arguments.s3BucketName#/#arguments.objectKey#?#contentDisposition#";
		fullURLWithSignature = "http://s3.amazonaws.com/#arguments.s3BucketName#/#arguments.objectKey#?AWSAccessKeyId=#URLEncodedFormat(variables.awsAccessKey)#&Expires=#epochTime#&#contentDisposition#";
		if (len(trim(arguments.fileNameToUse))) {
			awsGetRequest &= ";filename=" & trim(arguments.fileNameToUse);
			fullURLWithSignature &= "%3Bfilename%3D" & trim(arguments.fileNameToUse);
		}
		if (len(trim(arguments.mimeType))) {
			awsGetRequest &= "&response-content-type=" & trim(arguments.mimeType);
			fullURLWithSignature &= "&response-content-type=" & trim(arguments.mimeType);
		}
		// create the HMAC hashed and binary encoded signature
		signature = createEncodedSignature(awsGetRequest);
		// Add the signature to the URL to return
		fullURLWithSignature &= "&Signature=#URLEncodedFormat(signature)#";
		return fullURLWithSignature;
	}


	/**
	*	@description Takes the URL string you need to sign and encodes it per AWS specs
	*/
	private string function createEncodedSignature(required string awsGetRequest) {
		// AWS requests require that you replace "\n" with "chr(10)" to get a correct digest
		var fixedData = replace(arguments.awsGetRequest,"\n","#chr(10)#","all");
		// Make a HmacSHA1 hash of the AWS GET request and encode it properly for AWS. We hash the GET request with our AWS Secret Key.
		// Note that hmac() was added in CF10 and will not work in earlier versions of Adobe ColdFusion.
		var digest = hmac(fixedData, variables.awsSecretKey, "HmacSHA1", "utf-8");
		var signature = binaryEncode(binaryDecode(digest,"hex"),"base64");
		return signature;
	}

}
