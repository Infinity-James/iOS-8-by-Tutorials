//
//  ActionRequestHandler.swift
//  Quicker Bit
//
//  Created by James Valaitis on 08/07/2015.
//  Copyright (c) 2015 Ray Wenderlich LLC. All rights reserved.
//

import BitlyKit
import MobileCoreServices
import UIKit

//	MARK: Action Request Handler Class
class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
	
	//	MARK: Properties
    var extensionContext: NSExtensionContext?
	
	//	MARK: NSExtensionRequestHandling Methods
    func beginRequestWithExtensionContext(context: NSExtensionContext) {
		//	hold context
        extensionContext = context
		
		//	unwrap item provider
		let propertyListType = String(kUTTypePropertyList)
		if let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
			let itemProvider = extensionItem.attachments?.first as? NSItemProvider where itemProvider.hasItemConformingToTypeIdentifier(propertyListType) {
				itemProvider.loadItemForTypeIdentifier(propertyListType, options: nil) { item, error in
					let dictionary = item as! NSDictionary
					NSOperationQueue.mainQueue().addOperationWithBlock {
						let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! [NSObject: AnyObject]
						self.itemLoadCompletedWithPreprocessingResults(results)
					}
				}
		} else {
			doneWithResults(nil)
		}
	}
	
	//	MARK: JavaScript Parsing
    private func itemLoadCompletedWithPreprocessingResults(javaScriptPreprocessingResults: [NSObject: AnyObject]) {
        //	
		if let currentURLString = javaScriptPreprocessingResults["currentURL"] as? String where !currentURLString.isEmpty {
			let bitlyService = BitlyService(accessToken: "")
			if let longURL = NSURL(string: currentURLString) {
				bitlyService.shortenUrl(longURL, domain: "bit.ly") { shortURLModel, error in
					if let error = error {
						self.doneWithResults(["error": error.localizedDescription])
					} else if let shortURL = shortURLModel?.shortUrl {
						UIPasteboard.generalPasteboard().string = shortURL.absoluteString
						let results = ["shortURL": shortURL.absoluteString ?? ""]
						
						let historyService = BitlyHistoryService.sharedService
						historyService.addItem(shortURLModel!)
						historyService.persistItemsArray()
						
						self.doneWithResults(results)
					} else {
						self.doneWithResults(["error": "Unable to shorten URL."])
					}
				}
			}
		}
    }
	
	//	MARK: Extension Management
    func doneWithResults(resultsForJavaScriptFinalizeArg: [NSObject: AnyObject]?) {
		if let results = resultsForJavaScriptFinalizeArg {
			let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: results]
			
			let itemType = String(kUTTypePropertyList)
			let resultsProvider = NSItemProvider(item: resultsDictionary, typeIdentifier: itemType)
			let resultsItem = NSExtensionItem()
			resultsItem.attachments = [resultsProvider]
			extensionContext!.completeRequestReturningItems([resultsItem], completionHandler: nil)
		} else {
			extensionContext!.completeRequestReturningItems(nil, completionHandler: nil)
		}
		
		extensionContext = nil
	}

}
