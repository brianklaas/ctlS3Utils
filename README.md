#CTL S3 Signing Utility

The sole purpose of this CFC is to create signed AWS S3 URLs so that you can add request headers to S3 requests.

For more information about adding request headers to GET requests in S3, see the [Amazon S3 docs](http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGET.html). 

### Requirements

This component uses the hmac() function introduced in Adobe ColdFusion 10. It will not work with earlier versions of Adobe ColdFusion, though you are welcome to provide your own hmac() implementation to get it to work with earlier versions of Adobe ColdFusion.

#### Methods

There are two methods to this component:

**init()**

Required Arguments

* awsAccessKey = the access key value of an Amazon IAM account that has permissions to read the requested S3 bucket.

* awsSecretKey = the secret key value of an Amazon IAM account that has permissions to read the requested S3 bucket.

**createSignedURL()**

Required Arguments

 * s3BucketName = the name of the S3 bucket where the object you are requesting resides.
 * objectKey = the path to and file name of the file in the specified bucket (ie; path/to/file.pdf)

Optional Arguments

 * expiresOnDate = the date/time on which this signed URL expires. Defaults to one hour from Now().
 * fileNameToUse = string value of the alternate file name to serve the file as.
 * isAttachment = boolean indicating if the file should be served as an attachment (download). Otherwise the file is served inline.
 * mimeType = string value representing the MIME type of the content.

