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

public class BitlyService {
  
  let accessToken: String
  let session: NSURLSession
  let bitlyAPIBaseUrlString = "https://api-ssl.bitly.com/"
  
  public init(accessToken: String) {
    self.accessToken = accessToken
    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    session = NSURLSession(configuration: sessionConfig)
  }
  
  public func shortenUrl(longUrl: NSURL, domain: String, completion:(BitlyShortenedUrlModel?, NSError?) -> ()) {
    let urlComponents: NSURLComponents = NSURLComponents(string: bitlyAPIBaseUrlString)!
    urlComponents.path = "/v3/shorten"
    
    let accessTokenItem = NSURLQueryItem(name: "access_token", value: accessToken)
    let longUrlItem = NSURLQueryItem(name: "longUrl", value: longUrl.absoluteString ?? "")
    let domainItem = NSURLQueryItem(name: "domain", value: domain)
    
    urlComponents.queryItems = [accessTokenItem, longUrlItem, domainItem]
    
    if let url = urlComponents.URL {
      let request = NSURLRequest(URL: url)
      
      let dataTask = session.dataTaskWithRequest(request) { data, response, error in
        NSOperationQueue.mainQueue().addOperationWithBlock {
          if error != nil {
            completion(nil, error)
          } else {
            var jsonError: NSError?
            let responseDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! NSDictionary
            if jsonError != nil {
              completion(nil, jsonError)
            } else {
              let json = JSON(responseDictionary)
              let statusCode = json["status_code"].int
              if statusCode == 200 {
                let shortUrl = BitlyShortenedUrlModel(fromJSON: json)
                completion(shortUrl, nil)
              } else {
                let statusCodeError = NSError(domain: "com.raywenderlich.bitlykit", code: statusCode!, userInfo: nil)
                completion(nil, statusCodeError)
              }
            }
          }
        }
      }
      dataTask.resume()
    } else {
      fatalError("Failed to build URL for /shorten API Endpoint.")
    }
  }
}