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

import UIKit
import S3Kit

public protocol ThumbnailDelegate {
  func didSelectImage(image : S3Image)
}

public class ThumbnailCollectionViewController: UICollectionViewController {
  
  var s3Bucket : BucketInfo!
  public var delegate: ThumbnailDelegate?
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = UIColor.whiteColor()
    
    s3Bucket = BucketInfo()
  }
  
  override public func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    let cv = self.collectionView!
    let loadBlock = {
      dispatch_async(dispatch_get_main_queue(), {
        cv.reloadData()
      })
    }
    s3Bucket.load(loadBlock, thumbnailBlock: { indexPath in
      dispatch_async(dispatch_get_main_queue()) {
        cv.reloadItemsAtIndexPaths([indexPath])
      }
    })
  }
  
  //MARK: - UICollectionViewDataSource
  
  override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return s3Bucket.fileCount()
  }
  
  override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ThumbCell", forIndexPath: indexPath) as! ThumbnailCell
    let imageWrapper = s3Bucket.objAtIndex(indexPath)
    cell.setImageURL(imageWrapper.url)
    return cell
  }
  
  override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let imWrapper = s3Bucket.objAtIndex(indexPath) as S3Image
    delegate?.didSelectImage(imWrapper)
  }
  
  func copyFile(src : NSURL, dst: NSURL) {
    var error : NSErrorPointer!
    NSFileManager.defaultManager().copyItemAtURL(src, toURL: dst, error: error)
    if error != nil {
      println(error!)
    }
  }
  
}
