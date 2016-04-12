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

import Foundation
import Swift
import UIKit

let ACCESS_KEY_ID = "AKIAJSJ7A2R45FXJX5KA"
let SECRET_KEY = "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"
let BUCKET_NAME = "imgvue-document-provider"

public class BucketInfo {
  var files : [S3Image] = []
  let s3 : S3Wrapper
  
  public init() {
    s3 = S3Wrapper(accessKey: ACCESS_KEY_ID, secretKey: SECRET_KEY)
  }
  
  public func load(imageKey : String) -> NSData? {
    return self.s3.getObject(imageKey, bucket: BUCKET_NAME)
  }
  
  public func load(initalLoadBlock : () -> (), thumbnailBlock : (indexPath : NSIndexPath) -> ()) {
    let keys = s3.listObjects(BUCKET_NAME) as! [String]
  
    let fileManager = NSFileManager()
    let fileArray = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
  
    var images : [S3Image] = []
  
    for key : String in keys {
      let imWrapper = S3Image(key: key)
      images.append(imWrapper)
  
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        if let data : NSData = self.s3.getObject(key, bucket: BUCKET_NAME) {
          let url = fileArray[0].URLByAppendingPathComponent(key);
          data.writeToURL(url, atomically: true)
          imWrapper.url = url;
  
          let arr : NSArray = images
          let row = arr.indexOfObject(imWrapper)
          let indexPath =  NSIndexPath(forRow: row, inSection: 0)
          thumbnailBlock(indexPath: indexPath)
        }
      }
    }
  
    files = images
    initalLoadBlock()
  }
  
  public func fileCount() -> Int {
    return files.count
  }
  
  public func objAtIndex(indexPath : NSIndexPath) -> S3Image {
    return files[indexPath.row]
  }
  
  public func uploadImage(image: UIImage, name : String, completion:(imageObj:S3Image!, error:NSError!) -> ()) {
    let imageData = UIImageJPEGRepresentation(image, 0.9)
    let error = s3.putJPEG(imageData, key: name, bucket: BUCKET_NAME)
  
    var imageObj : S3Image!
    if error == nil {
      imageObj = S3Image()
  
      let fileManger = NSFileManager.defaultManager()
      let fileArray: NSArray = fileManger.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
      let filePath = "\(fileArray.lastObject)/\(name)"
    }
    completion(imageObj: imageObj, error: error)
  }
  
  public func uploadData(data: NSData, name: String, completion:(error:NSError!) -> ()) {
    let error = s3.putJPEG(data, key: name, bucket: BUCKET_NAME)
    completion(error: error)
  }
  
}
