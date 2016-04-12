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
import BitlyKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "History"
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return BitlyHistoryService.sharedService.items.count;
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let shortenedUrl = BitlyHistoryService.sharedService.items[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("Item") as! UITableViewCell
    cell.textLabel!.text = shortenedUrl.shortUrl?.absoluteString
    cell.detailTextLabel?.text = shortenedUrl.longUrl?.absoluteString
    
    return cell
  }
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let shortUrl = BitlyHistoryService.sharedService.items[indexPath.row]
    let alertController = UIAlertController(title: "Copy Link to Clipboard", message: "Choose which link you want to copy to your clipboard.", preferredStyle: .ActionSheet)
    
    let shortLinkAction = UIAlertAction(title: "Short Link", style: .Default) { _ in
      UIPasteboard.generalPasteboard().URL = shortUrl.shortUrl
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    let longLinkAction = UIAlertAction(title: "Long Link", style: .Default) { _ in
      UIPasteboard.generalPasteboard().URL = shortUrl.longUrl
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    alertController.addAction(shortLinkAction)
    alertController.addAction(longLinkAction)
    alertController.addAction(cancelAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
}