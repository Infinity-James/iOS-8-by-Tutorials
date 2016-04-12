//
//  NavigationController.swift
//  KhromaPal
//
//  Created by James Valaitis on 11/06/2015.
//  Copyright (c) 2015 RayWenderlich. All rights reserved.
//

import Foundation

class NavigationController: UINavigationController, PaletteDisplayContainer, PaletteSelectionContainer {
	func currentlyDisplayedPalette() -> ColorPalette? {
		if let topVC = topViewController as? PaletteDisplayContainer {
			return topVC.currentlyDisplayedPalette()
		}
		
		return nil
	}
	
	func currentlySelectedPalette() -> ColorPalette? {
		if let topVC = topViewController as? PaletteSelectionContainer {
			return topVC.currentlySelectedPalette()
		}
		
		return nil
	}
}