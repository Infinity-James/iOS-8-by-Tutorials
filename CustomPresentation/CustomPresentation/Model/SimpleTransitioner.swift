//
//  SimpleTransitioner.swift
//  CustomPresentation
//
//  Created by James Valaitis on 21/06/2015.
//  Copyright (c) 2015 Fresh App Factory. All rights reserved.
//

import UIKit

//	MARK: Simple Transitioner Class
class SimpleAnimatedTransitioner: NSObject, UIViewControllerAnimatedTransitioning {
	//	MARK: Properties
	var isPresentation = true
	
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
		let dismissedFrame = appearedFrame.rectByOffsetting(dx: 0.0, dy: CGRectGetHeight(appearedFrame))
		
		let initialFrame = isPresentation ? dismissedFrame : appearedFrame
		let finalFrame = isPresentation ? appearedFrame : dismissedFrame
		
		animatingView.frame = initialFrame
		
		UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 300.0, initialSpringVelocity: 5.0, options: .AllowUserInteraction, animations: {
			animatingView.frame = finalFrame
		}, completion: { success in
			if !self.isPresentation {
				fromView.removeFromSuperview()
			}
			transitionContext.completeTransition(success)
		})
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
		return 0.5
	}
}

//	MARK: Simple Transitioning Delegate
class SimpleTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
	
	//	MARK: UIViewControllerTransitioningDelegate Methods
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = SimpleAnimatedTransitioner()
		animationController.isPresentation = false
		return animationController
	}
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = SimpleAnimatedTransitioner()
		animationController.isPresentation = true
		return animationController
	}
	
	func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
		let presentationController = SimplePresentationController(presentedViewController: presented, presentingViewController: presenting)
		return presentationController
	}
}