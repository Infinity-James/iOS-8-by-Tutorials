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
import QuartzCore
import BitlyKit

class ViewController: UIViewController {
	
	enum ActionButtonState {
		case Shorten
		case Copy
	}
	
	let bitlyService: BitlyService
	
	@IBOutlet var longUrlTextField: UITextField!
	@IBOutlet var domainSegmentedControl: UISegmentedControl!
	@IBOutlet var actionButton: UIButton!
	@IBOutlet var copiedLabel: UILabel!
	
	var actionButtonState: ActionButtonState = .Shorten
	var shortenedUrl: BitlyShortenedUrlModel!
	
	required init(coder aDecoder: NSCoder)  {
		bitlyService = BitlyService(accessToken: "320c72f42cbbf70ef2fafb61fba8e1f0e5b29b59")
		
		super.init(coder: aDecoder)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "respondToUIApplicationDidBecomeActiveNotification", name: UIApplicationDidBecomeActiveNotification, object: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		actionButton.layer.borderColor = UIColor.whiteColor().CGColor
		actionButton.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
		actionButton.layer.cornerRadius = 15.0
		copiedLabel.hidden = true
		setupLongUrlTextFieldAppearance()
	}
	
	override func viewWillAppear(animated: Bool) {
		navigationController?.setNavigationBarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition(nil) { _ in
			self.setupLongUrlTextFieldAppearance()
		}
	}
	
	func respondToUIApplicationDidBecomeActiveNotification() {
		resetView()
		askToUseClipboardIfUrlPresent();
	}
	
	func askToUseClipboardIfUrlPresent() {
		if let pasteBoardUrl = UIPasteboard.generalPasteboard().URL {
			if pasteBoardUrl.host != "bit.ly" || pasteBoardUrl.host != "bitly.com" || pasteBoardUrl.host != "j.mp" {
				// don't ask to shorten urls we know are already shortened
				let alertController = UIAlertController(title: "Shorten clipboard item?", message: pasteBoardUrl.absoluteString, preferredStyle: .Alert)
				let yesAction = UIAlertAction(title: "Yes", style: .Default) { action in
					self.addPasteboardUrlToLongUrlTextField()
					self.dismissViewControllerAnimated(true, completion: nil)
				}
				let noAction = UIAlertAction(title: "No", style: .Cancel) { action in
					self.dismissViewControllerAnimated(true, completion: nil)
				}
				alertController.addAction(yesAction)
				alertController.addAction(noAction)
				
				presentViewController(alertController, animated: true, completion: nil)
			}
		}
	}
	
	func addPasteboardUrlToLongUrlTextField() {
		if let url = UIPasteboard.generalPasteboard().URL {
			longUrlTextField.text = url.absoluteString
		}
	}
	
	@IBAction func longUrlTextFieldChanged(sender: UIButton) {
		actionButtonState = .Shorten
		actionButton.setTitle("Shorten", forState: .Normal)
		copiedLabel.hidden = true
	}
	
	@IBAction func actionButtonPressed(sender: UIButton) {
		longUrlTextField.resignFirstResponder()
		switch (actionButtonState) {
		case .Shorten:
			shortenUrl()
		case .Copy:
			UIPasteboard.generalPasteboard().URL = shortenedUrl.shortUrl
			copiedLabel.hidden = false
		}
	}
	
	func shortenUrl() {
		var domain: String
		switch (domainSegmentedControl.selectedSegmentIndex) {
		case 1:
			domain = "j.mp"
		case 2:
			domain = "bitly.com"
		default:
			domain = "bit.ly"
		}
		
		var longUrlOpt: NSURL? = NSURL(string: self.longUrlTextField.text)
		if let longUrl = longUrlOpt {
			bitlyService.shortenUrl(longUrl, domain: domain) { shortenedUrlResult, error in
				if error != nil {
					self.presentError()
				} else {
					dispatch_async(dispatch_get_main_queue()) {
						self.shortenedUrl = shortenedUrlResult!
						self.actionButton.setTitle(self.shortenedUrl.shortUrl?.absoluteString, forState: .Normal)
						self.actionButtonState = .Copy
						BitlyHistoryService.sharedService.addItem(self.shortenedUrl)
					}
				}
			}
		}
	}
	
	func presentError() {
		let alertController = UIAlertController(title: "Unable to Shorten", message: "Check your entered URL's format and try again", preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "OK", style: .Default) { action in
			self.dismissViewControllerAnimated(true, completion: nil)
		}
		
		alertController.addAction(okAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func setupLongUrlTextFieldAppearance() {
		let attributedPlaceHolderString = NSAttributedString(string: "URL", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
		longUrlTextField.attributedPlaceholder = attributedPlaceHolderString
		let bottomBorder = CALayer()
		bottomBorder.frame = CGRectMake(0.0, CGRectGetHeight(longUrlTextField.frame)-2, CGRectGetWidth(longUrlTextField.frame), 2.0);
		bottomBorder.backgroundColor = UIColor.whiteColor().CGColor
		longUrlTextField.layer.addSublayer(bottomBorder)
	}
	
	func resetView() {
		longUrlTextField.text = ""
		actionButtonState = .Shorten
		actionButton.setTitle("Shorten", forState: .Normal)
		copiedLabel.hidden = true
	}
	
}

