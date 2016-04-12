//
//  PaddedLabel.swift
//  KhromaLike
//
//  Created by James Valaitis on 14/06/2015.
//  Copyright (c) 2015 RayWenderlich. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
	var verticalPadding = 0.0
	
	//	MARK: UITraitEnvironment Methods
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		switch traitCollection.verticalSizeClass {
		case .Compact:
			verticalPadding = 0.0
		case .Regular:
			verticalPadding = 20.0
		case .Unspecified:
			break
		}
		invalidateIntrinsicContentSize()
	}
	
	//	MARK: View Methods
	override func intrinsicContentSize() -> CGSize {
		var intrinsicSize = super.intrinsicContentSize()
		
		//	add the padding
		intrinsicSize.height += CGFloat(verticalPadding)
		
		return intrinsicSize
	}
}