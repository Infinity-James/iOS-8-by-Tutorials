//
//  File.swift
//  KhromaPal
//
//  Created by James Valaitis on 11/06/2015.
//  Copyright (c) 2015 RayWenderlich. All rights reserved.
//

import Foundation

protocol PaletteDisplayContainer {
	func currentlyDisplayedPalette() -> ColorPalette?
}

protocol PaletteSelectionContainer {
	func currentlySelectedPalette() -> ColorPalette?
}