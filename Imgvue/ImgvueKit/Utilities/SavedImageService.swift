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

public class SavedImageService {
  
  public init() {
    
  }
  
  public func savedImageFileNames() -> [String] {
    var error: NSError?
    var imageNames = [String]()
    if let path = imagesDirectoryURL().path {
        imageNames = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: &error) as! [String]
    }
    
    if error != nil {
      NSLog("Error loading images: %@", error!)
    }
    
    return imageNames
  }
  
  public func imageNamed(imageName: String) -> UIImage? {
    var imageURL = imagesDirectoryURL()
    imageURL = imageURL.URLByAppendingPathComponent(imageName)
    
    var image: UIImage?
    if let path = imageURL.path {
        image = UIImage(contentsOfFile: path)
    }
    
    return image
  }
  
  public func saveImage(image: UIImage, name: String) -> NSURL? {
    return saveImage(image, name: name, imageUrl: imagesDirectoryURL())
  }
  
  public func saveImageToUpload(image: UIImage, name: String) -> NSURL? {
    return saveImage(image, name: name, imageUrl: imagesToUploadDirectoryURL())
  }
  
  public func saveImage(image: UIImage, name: String, imageUrl: NSURL) -> NSURL? {
    var imageDirectoryURL = imageUrl
    imageDirectoryURL = imageDirectoryURL.URLByAppendingPathComponent(name)
    imageDirectoryURL = imageDirectoryURL.URLByAppendingPathExtension("jpg")
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    let saved = imageData.writeToFile(imageDirectoryURL.path!, atomically: true)
    return imageDirectoryURL
  }
  
  private func imagesDirectoryURL() -> NSURL {
    return urlForDirectoryWithName("Images")
  }
  
  private func imagesToUploadDirectoryURL() -> NSURL {
    return urlForDirectoryWithName("Uploads")
  }
  
  private func urlForDirectoryWithName(name: String) -> NSURL! {
    if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.andbeyond.swift.imgvue") {
      var contairURLWithName = containerURL.URLByAppendingPathComponent(name)
      if !NSFileManager.defaultManager().fileExistsAtPath(contairURLWithName.path!) {
        NSFileManager.defaultManager().createDirectoryAtPath(containerURL.path!, withIntermediateDirectories: false, attributes: nil, error: nil)
      }
      
      return containerURL
    } else {
      fatalError("Unable to obtain container URL for app group, verify your app group settings.")
    }
  }
}