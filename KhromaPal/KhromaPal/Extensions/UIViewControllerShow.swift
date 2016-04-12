//
//  UIViewControllerShow.swift
//  KhromaPal
//
//  Created by James Valaitis on 12/06/2015.
//  Copyright (c) 2015 RayWenderlich. All rights reserved.
//

import UIKit

extension UIViewController {
	func jv_showViewControllerWillResultInPush(sender: AnyObject?) -> Bool {
		if let target = targetViewControllerForAction("jv_showViewControllerWillResultInPush:", sender: sender) {
			return target.jv_showViewControllerWillResultInPush(sender)
		} else {
			return false
		}
	}
	
	func jv_showDetailViewControllerWillResultInPush(sender: AnyObject?) -> Bool {
		if let target = targetViewControllerForAction("jv_showDetailViewControllerWillResultInPush:", sender: sender) {
			return target.jv_showViewControllerWillResultInPush(sender)
		} else {
			return false
		}
	}
}

extension UINavigationController {
	override func jv_showViewControllerWillResultInPush(sender: AnyObject?) -> Bool {
		return true
	}
}

extension UISplitViewController {
	override func jv_showDetailViewControllerWillResultInPush(sender: AnyObject?) -> Bool {
		if let primaryVC = viewControllers.last as? UIViewController where collapsed {
			return primaryVC.jv_showViewControllerWillResultInPush(sender)
		}
		
		return false
	}
}