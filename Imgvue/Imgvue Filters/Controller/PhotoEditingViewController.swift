//
//  PhotoEditingViewController.swift
//  Imgvue Filters
//
//  Created by James Valaitis on 11/07/2015.
//  Copyright (c) 2015 Ray Wenderlich LLC. All rights reserved.
//

import ImgvueKit
import Photos
import PhotosUI
import UIKit

class PhotoEditingViewController: UIViewController, PHContentEditingController {
	
	//	MARK: Properties - State
	
	var currentFilterName: String?
	let filterService = ImageFilterService()
	var filteredImage: UIImage?
	var input: PHContentEditingInput?
	
	//  MARK: Properties - Subviews
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var addFilterButton: UIButton!
	@IBOutlet weak var undoButton: UIButton!
	
	//	MARK: Action Methods
	
	@IBAction private func undo() {
		if let input = input {
			imageView.image = input.displaySizeImage
			currentFilterName = nil
			filteredImage = nil
		}
	}
	
	@IBAction private func addFilter() {
		let alertController = UIAlertController(title: "Add Filter", message: "Choose a filter to apply to the image.", preferredStyle: .ActionSheet)
		for (name, filter) in filterService.availableFilters() {
			let action = UIAlertAction(title: name, style: .Default) { _ in
				if let input = self.input {
					self.filteredImage = self.filterService.applyFilter(filter, toImage: input.displaySizeImage)
					self.imageView.image = self.filteredImage
					self.currentFilterName = filter
				}
			}
			alertController.addAction(action)
		}
		let noneAction = UIAlertAction(title: "None", style: .Cancel) { _ in
			if let input = self.input {
				self.imageView.image = self.filteredImage
				self.currentFilterName = nil
				self.filteredImage = nil
			}
		}
		alertController.addAction(noneAction)
		presentViewController(alertController, animated: true, completion: nil)
	}
	
	
	//	MARK: PHContentEditingController Methods
	
	func canHandleAdjustmentData(adjustmentData: PHAdjustmentData?) -> Bool {
		return false
	}
	
	func startContentEditingWithInput(contentEditingInput: PHContentEditingInput?, placeholderImage: UIImage) {
		input = contentEditingInput
		
		if let input  = input {
			imageView.image = input.displaySizeImage
		}
	}
	
	func finishContentEditingWithCompletionHandler(completionHandler: ((PHContentEditingOutput!) -> Void)!) {
		if currentFilterName == nil || input == nil {
			cancelContentEditing()
			return
		}
		
		let queuePriority = CLong(DISPATCH_QUEUE_PRIORITY_DEFAULT)
		let backgroundQueue = dispatch_get_global_queue(queuePriority, 0)
		dispatch_async(backgroundQueue) {
			let output = PHContentEditingOutput(contentEditingInput: self.input)
			let archiveData = NSKeyedArchiver.archivedDataWithRootObject(self.currentFilterName!)
			let identifier = "com.andbeyond.imgvue-imgvue-filters"
			let adjustmentData = PHAdjustmentData(formatIdentifier: identifier, formatVersion: "1.0", data: archiveData)
			output.adjustmentData = adjustmentData
			
			if let path = self.input!.fullSizeImageURL.path {
				let image = UIImage(contentsOfFile: path)!
				let filteredImage = self.filterService.applyFilter(self.currentFilterName!, toImage: image)
				let jpegData = UIImageJPEGRepresentation(filteredImage, 1.0)
				var error: NSError?
				let saveSucceeded = jpegData.writeToURL(output.renderedContentURL, options: .DataWritingAtomic, error: &error)
				if saveSucceeded {
					completionHandler(output)
				} else {
					println("Error occured during save: \(error).")
				}
			} else {
				println("Error occured loading image.")
			}
		}
		
		
	}
	
	var shouldShowCancelConfirmation: Bool {
		return false
	}
	
	func cancelContentEditing() {
	}
	
}
