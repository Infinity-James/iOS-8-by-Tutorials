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

class ImageViewController: UIViewController {
  
  var image: UIImage?
  var filteredImage: UIImage?
  @IBOutlet var imageView: UIImageView!
  let imageFilterService = ImageFilterService()
  
  override func viewDidLoad() {
    let addFilterBarButton = UIBarButtonItem(title: "Add Filter", style: .Plain, target: self, action: "addFilter:")
    navigationItem.rightBarButtonItem = addFilterBarButton
    
    if let image = image {
      imageView.image = image
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  func addFilter(button: UIBarButtonItem) {
    let alertController = UIAlertController(title: "Add Filter", message: "Choose a filter to aply to the image.", preferredStyle: .ActionSheet)
    
    let filters = imageFilterService.availableFilters()
    for (name, filter) in filters {
      let filterAction = UIAlertAction(title: name, style: .Default) { _ in
        self.filteredImage = self.imageFilterService.applyFilter(filter, toImage: self.image!)
        self.imageView.image = self.filteredImage!
      }
      
      alertController.addAction(filterAction)
    }
    
    let noneAction = UIAlertAction(title: "None", style: .Cancel) { _ in
      self.imageView.image = self.image
    }
    alertController.addAction(noneAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
}