/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "S3Wrapper.h"

@import MobileCoreServices;

#import <AWSS3/AWSS3.h>
#import <AWSRuntime/AWSRuntime.h>


@interface S3Wrapper ()
@property (strong, nonatomic) AmazonS3Client* s3;
@end

@implementation S3Wrapper

- (instancetype) initWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey {
  self = [super init];
  if (self) {
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:accessKey withSecretKey:secretKey];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_EAST_1];

  }
  return self;
}

- (NSArray*) listObjects:(NSString*)bucket {
  S3ListObjectsRequest* lor = [[S3ListObjectsRequest alloc] initWithName:bucket];
  S3ListObjectsResponse* resp = [self.s3 listObjects:lor];
  S3ListObjectsResult* res = resp.listObjectsResult;
  
  NSMutableArray *keys = [NSMutableArray array];
  for (S3ObjectSummary *summary in res.objectSummaries) {
    [keys addObject:summary.key];
  }
  return keys;}

- (NSData*) getObject:(NSString*)key bucket:(NSString*)bucketName {
  S3GetObjectRequest* request = [[S3GetObjectRequest alloc] initWithKey:key withBucket:bucketName];
  S3GetObjectResponse* response = [self.s3 getObject:request];
  return response.body;
}

- (NSError*) putJPEG:(NSData*)imageData key:(NSString*)imageName bucket:(NSString*)bucketName
{
  S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:imageName inBucket:bucketName];
  putObjectRequest.contentType = (id) kUTTypeJPEG;
  putObjectRequest.data = imageData;
  
  S3PutObjectResponse* putObjectResponse = [self.s3 putObject:putObjectRequest];
  NSError* error = putObjectResponse.error;
  
  return error;
}

@end
