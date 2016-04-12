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
import UIKit

public class ImgurService: NSObject, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
  
  private let imgurClientId = "30850874c7f1d69"
  private let imgurAPIBaseUrlString = "https://api.imgur.com/3/"
  
  public var session: NSURLSession!
  private var progressCallbacks: Dictionary<NSURLSessionTask, (Float) -> ()> = Dictionary()
  private var completionCallbacks: Dictionary<NSURLSessionTask, (ImgurImage?, NSError?) -> ()> = Dictionary()
  
  public class var sharedService: ImgurService {
    struct Singleton {
      static let instance = ImgurService()
    }
    return Singleton.instance
  }
  
  private override init() {
    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    sessionConfig.HTTPAdditionalHeaders = ["Authorization": "Client-ID \(imgurClientId)",
      "Content-Type": "application/json"]

    super.init()
    
    session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
  }
  
  public func hotViralGalleryThumbnailImagesPage(page: Int, completion: ([ImgurImage]?, NSError?) -> ()) {
    let urlString = "gallery/hot/viral/\(page)"
    if let url = imgurAPIUrlWithPathComponents(urlString) {
      let request = NSURLRequest(URL: url)
      let task = session.dataTaskWithRequest(request) { data, response, error in
        if error == nil {
          var images: [ImgurImage] = []
          let jsonResponse = JSON(data: data, options: .AllowFragments, error: nil)
          let imagesArray = jsonResponse["data"].array ?? []
          for imageJSON in imagesArray {
            if !imageJSON["is_album"].bool! { // no album support
              let image = ImgurImage(fromJson: imageJSON)
              images.append(image)
            }
          }
          
          completion(images, nil)
        } else {
          completion(nil, error)
        }
      }
      
      task.resume()
    }
  }
  
  public func uploadImage(image: UIImage, title: NSString, completion: (ImgurImage?, NSError?) -> (), progressCallback: (Float) -> ()) {
    uploadImage(image, title: title, session: session, completion: completion, progressCallback: progressCallback)
  }
  
  public func uploadImage(image: UIImage, title: NSString, session: NSURLSession?, completion: (ImgurImage?, NSError?) -> (), progressCallback: (Float) -> ()) {
    if let url = imgurAPIUrlWithPathComponents("image") {
      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      let postBodyDict = ["title": title]
      
      let postBodyData = NSJSONSerialization.dataWithJSONObject(postBodyDict, options: nil, error: nil)
      request.HTTPBody = postBodyData
      
      let savedImageService = SavedImageService()
      let uuidString = NSUUID().UUIDString
      
      let imageToUploadUrl = savedImageService.saveImageToUpload(image, name: uuidString)
      
      var sessionToUse: NSURLSession
      
      if let session = session {
        sessionToUse = session
      } else {
        sessionToUse = self.session
      }
      if let uploadUrl = imageToUploadUrl {
        let task = sessionToUse.uploadTaskWithRequest(request, fromFile: uploadUrl)
        completionCallbacks[task] = completion
        progressCallbacks[task] = progressCallback
        
        task.resume()
      } else {
        let error = NSError(domain: "com.raywenderlich.imgvue.imgurservice", code: 1, userInfo: nil)
        completion(nil, error)
      }
    }
  }
  
  private func imgurAPIUrlWithPathComponents(components: String) -> NSURL? {
    let baseUrl = NSURL(string: imgurAPIBaseUrlString)
    let APIUrl = NSURL(string: components, relativeToURL: baseUrl)
    
    return APIUrl
  }
  
  // MARK - NSURLSessionTaskDelegate
  
  public func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    if let progressCallback = progressCallbacks[task] {
      let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
      dispatch_async(dispatch_get_main_queue()) {
        progressCallback(progress)
      }
      if totalBytesSent == totalBytesExpectedToSend {
        progressCallbacks.removeValueForKey(task)
      }
    }
  }
  
  public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    if let progressCallback = progressCallbacks[task] {
      progressCallbacks.removeValueForKey(task)
    }
    
    if let completionCallback = completionCallbacks[task] {
      completionCallbacks.removeValueForKey(task)
      
      
      if error != nil {
        completionCallback(nil, error)
      }
    }
  }
  
  public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    if let completionBlock = completionCallbacks[dataTask] {
      var jsonError: NSError?
      
      if jsonError == nil {
        let jsonResponse = JSON(data: data, options: .AllowFragments, error: nil)
        let imgurImage = ImgurImage(fromJson: jsonResponse["data"])
        dispatch_async(dispatch_get_main_queue()) {
          completionBlock(imgurImage, nil)
        }
      } else {
        completionBlock(nil, jsonError)
      }
    }
  }
}