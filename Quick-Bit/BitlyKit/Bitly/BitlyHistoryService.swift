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

public class BitlyHistoryService {
	
	public lazy var items: [BitlyShortenedUrlModel] = BitlyHistoryService.sharedService.loadItemsArray()
	
	public class var sharedService: BitlyHistoryService {
		struct Singleton {
			static let instance = BitlyHistoryService()
		}
		return Singleton.instance
	}
	
	init() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		let mainQueue = NSOperationQueue.mainQueue()
		
		notificationCenter.addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: mainQueue) { _ in
			self.persistItemsArray()
		}
		
		notificationCenter.addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: mainQueue) { _ in
			self.items = self.loadItemsArray()
		}
	}
	
	public func addItem(item: BitlyShortenedUrlModel) {
		
		let itemsNSArray = items as NSArray
		let itemIndex = itemsNSArray.indexOfObject(item)
		if itemIndex != NSNotFound {
			items.removeAtIndex(itemIndex)
		}
		
		items.insert(item, atIndex: 0)
	}
	
	public func loadItemsArray() -> [BitlyShortenedUrlModel] {
		var loadedItems: [BitlyShortenedUrlModel] = []
		let fileExists = NSFileManager.defaultManager().fileExistsAtPath(savedItemsFileUrl().path ?? "")
		if fileExists {
			var loadError: NSError?
			let itemsData = NSData(contentsOfFile: savedItemsFileUrl().path!, options: .DataReadingUncached, error: &loadError)
			if loadError != nil {
				NSLog("Error loading saved items array: %@", loadError!)
			} else {
				var unarchivedItems: [BitlyShortenedUrlModel]! = NSKeyedUnarchiver.unarchiveObjectWithData(itemsData!) as! Array
				if unarchivedItems != nil {
					loadedItems = unarchivedItems
				}
			}
		}
		
		return loadedItems
	}
	
	public func persistItemsArray() {
		let itemsData = NSKeyedArchiver.archivedDataWithRootObject(items)
		var saveError: NSError?
		itemsData.writeToURL(savedItemsFileUrl(), options: NSDataWritingOptions.AtomicWrite, error: &saveError)
		if saveError != nil {
			NSLog("Error persisting history items: %@", saveError!)
		}
	}
	
	func savedItemsFileUrl() -> NSURL {
		if let containerUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.andbeyond.swift.quickbit") {
			return containerUrl.URLByAppendingPathComponent("RWTBitlyHistoryServiceItems.dat")
		} else {
			fatalError("Unable to obtain shared container URL, verify that you've configured your App Group correctly.")
		}
	}
}