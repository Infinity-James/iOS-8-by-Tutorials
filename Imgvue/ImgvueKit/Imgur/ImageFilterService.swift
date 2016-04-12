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

public class ImageFilterService {
  
  public init() {
    
  }
  
  public func availableFilters() -> Dictionary<String, String> {
    return ["Sepia": "CISepiaTone",
      "Invert": "CIColorInvert",
      "Vintage": "CIPhotoEffectTransfer",
      "Black & White": "CIPhotoEffectMono"]
  }
  
  public func applyFilter(filterName: String, toImage image: UIImage) -> UIImage {
    let filter = CIFilter(name: filterName)
    filter.setDefaults()
    
    let orientation = orientationFromImageOrientation(image.imageOrientation)
    
    let ciImage = CIImage(CGImage: image.CGImage)
    let inputImage = ciImage.imageByApplyingOrientation(orientation)
    
    filter.setValue(inputImage, forKey: kCIInputImageKey)
    
    let outputImage = filter.outputImage
    
    let context = CIContext(options: nil)
    
    let cgImageRef = context.createCGImage(outputImage, fromRect: outputImage.extent())
    
    if let filteredImage = UIImage(CGImage: cgImageRef) {
      return filteredImage
    } else {
      return image
    }
  }
  
  private func orientationFromImageOrientation(imageOrientation: UIImageOrientation) -> CInt {
    var orientation: CInt = 0
    
    switch (imageOrientation) {
    case .Up:               orientation = 1
    case .Down:             orientation = 3
    case .Left:             orientation = 8
    case .Right:            orientation = 6
    case .UpMirrored:   	orientation = 2
    case .DownMirrored:     orientation = 4
    case .LeftMirrored:     orientation = 5
    case .RightMirrored:    orientation = 7
    }
    
    return orientation
  }
}