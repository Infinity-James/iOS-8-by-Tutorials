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
import ImgvueKit

class ImgurImageViewController: UIViewController {
  
  var imgurImage: ImgurImage?
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var progressView: UIProgressView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let imageTitle = imgurImage?.title {
      title = imageTitle
    }
    
    let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveImage:")
    navigationItem.rightBarButtonItem = saveBarButtonItem
    navigationItem.rightBarButtonItem!.enabled = false
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadImage()
  }
  
  func loadImage() {
    let progressBlock: SDWebImageDownloaderProgressBlock = {receivedSize, expectedSize in
      let progress = Float(receivedSize)/Float(expectedSize)
      dispatch_async(dispatch_get_main_queue()) {
        self.progressView.setProgress(progress, animated: true)
      }
    }
    
    let completedBlock: SDWebImageCompletedBlock = {image, error, cacheType in
      if error != nil {
        NSLog("Error loading image %@", error!)
      }
      
      self.progressView.hidden = true
      self.navigationItem.rightBarButtonItem!.enabled = true
    }
    if let imageLink = imgurImage?.link {
      imageView.setImageWithURL(imageLink, placeholderImage: nil, options: nil, progress: progressBlock, completed: completedBlock)
    }
    
  }
  
  func saveImage(button: UIBarButtonItem) {
    navigationItem.rightBarButtonItem!.enabled = false
    let savedImageService = SavedImageService()
    if let imageId = imgurImage?.imgurId {
      savedImageService.saveImage(imageView.image!, name: imageId)
    }
  }
}