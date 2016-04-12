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

public class BitlyShortenedUrlModel: NSObject, NSCoding {
  
  public let globalHash: String
  public let privateHash: String
  public let longUrl: NSURL?
  public let shortUrl: NSURL?
  
  public init(fromJSON json: JSON) {
    globalHash = json["data"]["global_hash"].string!
    privateHash = json["data"]["hash"].string!
    
    let longUrlString = json["data"]["long_url"].string!
    if let longUrl = NSURL(string: longUrlString) {
      self.longUrl = longUrl
    } else {
      self.longUrl = nil
    }
    
    let shortUrlString = json["data"]["url"].string!
    if let shortUrl = NSURL(string: shortUrlString) {
      self.shortUrl = shortUrl
    } else {
      self.shortUrl = nil
    }
    
    super.init()
  }
  
  public required init(coder aDecoder: NSCoder) {
    globalHash = aDecoder.decodeObjectForKey("globalHash") as! String
    privateHash = aDecoder.decodeObjectForKey("privateHash") as! String
    longUrl = aDecoder.decodeObjectForKey("longUrl") as? NSURL
    shortUrl = aDecoder.decodeObjectForKey("shortUrl") as? NSURL
  }
  
  public func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(globalHash, forKey: "globalHash")
    aCoder.encodeObject(privateHash, forKey: "privateHash")
    aCoder.encodeObject(longUrl, forKey: "longUrl")
    aCoder.encodeObject(shortUrl, forKey: "shortUrl")
  }
  
}