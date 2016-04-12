//  RWTController.swift

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

class RWTViewController: UIViewController {
  
  @IBOutlet weak var mainTextField: UITextView!
  
  // #pragma mark - View Load / Unload
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // #pragma mark - View Appear / Disappear
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Listen for changes to keyboard visibility
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
    NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
  }
  
  // #pragma mark - Keyboard Event Notifications
  
  func keyboardWillShowNotification(notification: NSNotification) {
    keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
  }
  
  func keyboardWillHideNotification(notification: NSNotification) {
    keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
  }
  
  // #pragma mark - Convenience
  
  func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool) {
    let userInfo = notification.userInfo
    var info = notification.userInfo!
    
    // Convert keyboard frame from screen to view coordinates
    let keyboardScreenBeginFrame = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
    let keyboardScreenEndFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    
    let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
    let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
    let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
    
    let navigationHeader = view.convertRect(self.navigationController!.navigationBar.frame, fromView: view.window)
    mainTextField.contentInset = UIEdgeInsetsMake(navigationHeader.height, 0, keyboardScreenEndFrame.height, 0)
  }
}