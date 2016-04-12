//
//  AwesomeTransitioner.swift
//  CustomPresentation
//
//  Created by James Valaitis on 22/06/2015.
//  Copyright (c) 2015 Fresh App Factory. All rights reserved.
//

import UIKit

//	MARK: Awesome Animated Transitioning Class
class AwesomeAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	//	MARK: Properties
	let isPresentation: Bool
	let selectedObject: SelectionObject
	
	//	MARK: Initisalisation
	init(selectedObject: SelectionObject, isPresentation: Bool) {
		self.selectedObject = selectedObject
		self.isPresentation = isPresentation
	}
	
	//	MARK: UIViewControllerAnimatedTransitioning Methods
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		let fromView = fromViewController.view
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let toView = toViewController.view
		
		let containerView = transitionContext.containerView()
		if isPresentation {
			containerView.addSubview(toView)
		}
		
		let animatingViewController = isPresentation ? toViewController : fromViewController
		let animatingView = animatingViewController.view
		
		let appearedFrame = transitionContext.finalFrameForViewController(animatingViewController)
		let dismissedFrame = appearedFrame.rectByOffsetting(dx: 0.0, dy: appearedFrame.height)
		
		let initialFrame = isPresentation ? dismissedFrame : appearedFrame
		let finalFrame = isPresentation ? appearedFrame : dismissedFrame
		
		animatingView.frame = initialFrame
		
		var countriesViewController = (isPresentation ? fromViewController : toViewController) as! CountriesViewController
		if !isPresentation {
			countriesViewController.hideImage(true, indexPath: selectedObject.selectedIndexPath)
		}
		
		UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .AllowUserInteraction | .BeginFromCurrentState, animations: {
			animatingView.frame = finalFrame
			countriesViewController.changeCellSpacingForPresentation(self.isPresentation)
			}, completion: { success in
				if !self.isPresentation {
					countriesViewController.hideImage(false, indexPath: self.selectedObject.selectedIndexPath)
					UIView.animateWithDuration(0.3, animations: {
						fromView.alpha = 0.0
					}, completion: { success in
						fromView.removeFromSuperview()
						transitionContext.completeTransition(success)
					})
				} else {
					transitionContext.completeTransition(success)
				}
		})
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
		return 0.7
	}
}

//	MARK: Awesome Transitioning Delegate Class
class AwesomeTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
	//	MARK: Properties
	let selectedObject: SelectionObject
	
	//	MARK: Initisalisation
	init(selectedObject: SelectionObject) {
		self.selectedObject = selectedObject
	}
	
	//	MARK: UIViewControllerTransitioningDelegate Methods
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = AwesomeAnimatedTransitioning(selectedObject: selectedObject, isPresentation: false)
		return animationController
	}
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = AwesomeAnimatedTransitioning(selectedObject: selectedObject, isPresentation: true)
		return animationController
	}
	
	func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
		let presentationController = AwesomePresentationController(presentedViewController: presented, presentingViewController: presenting)
		presentationController.selectionObject = selectedObject
		return presentationController
	}
}