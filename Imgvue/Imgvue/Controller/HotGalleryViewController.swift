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

class HotGalleryViewController: UIViewController, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet var imagesCollectionView: UICollectionView!
  var progressView: UIProgressView!
  var images: [ImgurImage] = []
  
  override func viewDidLoad() {
    super.viewDidLoad();
    
    let progressNavigationController = navigationController as! ProgressNavigationController
    progressView = progressNavigationController.progressView
    
    progressView.hidden = true
    ImgurService.sharedService.hotViralGalleryThumbnailImagesPage(0) { images, error in
      if error == nil {
        self.images = images!
        dispatch_async(dispatch_get_main_queue()) {
          self.imagesCollectionView.reloadData()
        }
      } else {
        NSLog("Error fetching hot images: %@", error!)
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "ViewImage" {
      let imageViewController = segue.destinationViewController as! ImgurImageViewController
      let cell = sender as! ImageCollectionViewCell
      if let indexPath = imagesCollectionView.indexPathForCell(cell) {
        imageViewController.imgurImage = images[indexPath.row]
      }
    }
  }
  
  @IBAction func share(sender: UIBarButtonItem) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .SavedPhotosAlbum
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    dismissViewControllerAnimated(true, completion: nil)
    
    let completedBlock: (ImgurImage?, NSError?) -> () = { image, error in
      if error == nil {
        if let imageLink = image?.link {
          let alertController = UIAlertController(title: "Upload Finished",
            message: "URL: \(imageLink.absoluteString!)",
            preferredStyle: .Alert)
          
          let openAction = UIAlertAction(title: "Open", style: .Default) { _ in
            let _ = UIApplication.sharedApplication().openURL(imageLink)
          }
          
          let copyAction = UIAlertAction(title: "Copy", style: .Default) { _ in
            UIPasteboard.generalPasteboard().URL = imageLink
          }
          
          alertController.addAction(openAction)
          alertController.addAction(copyAction)
          self.presentViewController(alertController, animated: true, completion: nil)
          
          self.progressView.hidden = true
          self.progressView.setProgress(0, animated: false)
        }
      } else {
        NSLog("Upload error: %@", error!)
        self.progressView.hidden = true
      }
    }
    
    let progressBlock: (Float) -> () = { progress in
      if progress > 0 {
        self.progressView.hidden = false;
        self.progressView.setProgress(progress, animated: true)
      }
    }
    
    ImgurService.sharedService.uploadImage(selectedImage, title: "Swift", completion: completedBlock, progressCallback: progressBlock)
  }
  
  // MARK - UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
    cell.imgurImage = images[indexPath.row]
    
    return cell
  }
}