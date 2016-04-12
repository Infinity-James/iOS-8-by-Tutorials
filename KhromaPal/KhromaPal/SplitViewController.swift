//
//  SplitViewController.swift
//  KhromaPal
//
//  Created by James Valaitis on 11/06/2015.
//  Copyright (c) 2015 RayWenderlich. All rights reserved.
//

import UIKit

//	MARK: Split View Controller Class
class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		delegate = self
	}
	
	//	MARK: UISplitViewControllerDelegate Methods
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
		if let selectionContainer = primaryViewController as? PaletteSelectionContainer,
			let displayContainer = secondaryViewController as? PaletteDisplayContainer,
			let selectedPalette = selectionContainer.currentlySelectedPalette()
			where selectedPalette == displayContainer.currentlyDisplayedPalette() {
			return false
		}
		
		return true
	}
	
	func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController!) -> UIViewController? {
		if let paletteDisplayContainer = primaryViewController as? PaletteDisplayContainer where paletteDisplayContainer.currentlyDisplayedPalette() != nil {
			return nil
		}
		
		let noneSelectedVC = storyboard?.instantiateViewControllerWithIdentifier("NoPaletteSelected") as! UIViewController
		return NavigationController(rootViewController: noneSelectedVC)
	}
}
