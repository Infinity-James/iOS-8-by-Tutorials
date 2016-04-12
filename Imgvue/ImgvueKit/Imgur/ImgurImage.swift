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

public class ImgurImage {
  
  public let imgurId: String
  public let title: String
  public let link: NSURL?
  public let largeThumbnailLink: NSURL?
  
  public init(fromJson json: JSON) {
    imgurId = json["id"].string!
    title = json["title"].string ?? ""
    let urlString = json["link"].string!
    if let link = NSURL(string: urlString) {
      self.link = link
    } else {
      self.link = nil
    }
    
    let thumbnailUrlString = "http://i.imgur.com/\(imgurId)l.jpg"
    if let largeThumbnailLink = NSURL(string: thumbnailUrlString) {
      self.largeThumbnailLink = largeThumbnailLink
    } else {
      self.largeThumbnailLink = nil
    }
  }
  
}