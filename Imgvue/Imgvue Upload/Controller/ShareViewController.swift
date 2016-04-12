//
//  ShareViewController.swift
//  Imgvue Upload
//
//  Created by James Valaitis on 06/07/2015.
//  Copyright (c) 2015 Ray Wenderlich LLC. All rights reserved.
//

import ImgvueKit
import MobileCoreServices
import Social
import UIKit

//	MARK: Share View Controller Class
class ShareViewController: SLComposeServiceViewController {

	//	MARK: Properties
	var imageToShare: UIImage?
	
	//	MARK: SLComposeServiceViewController
    override func isContentValid() -> Bool {
		if imageToShare == nil {
			return false
		}
		
        return true
    }

    override func didSelectPost() {
        shareImage()
    }

    override func configurationItems() -> [AnyObject]! {
		let configItem = SLComposeSheetConfigurationItem()
		configItem.title = "URL will be copied to the clipboard."
        return [configItem]
    }
	
	//	MARK: Upload Methods
	
	private func shareImage() {
		//	obtain headers that Imgur's singleton provides
		let defaultHeaders = ImgurService.sharedService.session.configuration.HTTPAdditionalHeaders
		
		//	create session background upload
		let sessionID = "com.andbeyond.imgvue.backgroundsession"
		let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionID)
		config.sharedContainerIdentifier = "group.com.andbeyond.swift.imgvue"
		config.HTTPAdditionalHeaders = defaultHeaders
		
		let backgroundSession = NSURLSession(configuration: config, delegate: ImgurService.sharedService, delegateQueue: NSOperationQueue.mainQueue())
		
		//	create completion handler for when image finishes uploading
		let completion: (ImgurImage?, NSError?) -> () = { image, error in
			if let error = error {
				NSLog("Error sharing image: %@", error)
			} else {
				if let imageLink = image?.link {
					UIPasteboard.generalPasteboard().URL = imageLink
					NSLog("Image shared: %@", imageLink.absoluteString!)
				}
			}
		}
		
		//	log progress of upload
		let progressCallback: (Float) -> () = { progress in
			println("Uload progress for extension: \(progress)")
		}
		
		//	
		let title = contentText
		
		//	upload the image using the ImgurService
		ImgurService.sharedService.uploadImage(imageToShare!, title: title, session: backgroundSession, completion: completion, progressCallback: progressCallback)
		
		//	signify we are done with presenting anything to the user
		self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
	}

	//	MARK: View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var itemProvider: NSItemProvider? = nil
		
		if let items = extensionContext?.inputItems where !items.isEmpty {
			let item = items.first as! NSExtensionItem
			if let attachments = item.attachments where !attachments.isEmpty {
				itemProvider = attachments.first as? NSItemProvider
			}
		}
		
		let imageType = kUTTypeImage as String
		if let itemProvider = itemProvider where itemProvider.hasItemConformingToTypeIdentifier(imageType) {
			itemProvider.loadItemForTypeIdentifier(imageType, options: nil) { item, error in
				if error == nil {
					let url = item as! NSURL
					if let imageData = NSData(contentsOfURL: url) {
						self.imageToShare = UIImage(data: imageData)
					}
				} else {
					let title = "Unable to load image."
					let message = "Please try again or choose a different image"
					let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
					let action = UIAlertAction(title: "Fair Play", style: .Cancel) { _ in
						self.dismissViewControllerAnimated(true, completion: nil)
					}
					alert.addAction(action)
					self.presentViewController(alert, animated: true, completion: nil)
				}
			}
		}
	}
}
