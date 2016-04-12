//
//  SimplePresentationController.swift
//  CustomPresentation
//
//  Created by James Valaitis on 21/06/2015.
//  Copyright (c) 2015 Fresh App Factory. All rights reserved.
//

import UIKit

//	MARK: Simple Presentation Controller Class
class SimplePresentationController: UIPresentationController {
	
	//	MARK: Properties
	let dimmingView = UIView()
	
	//	MARK: Initialisation
	override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
		super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
		
		dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
		dimmingView.alpha = 0.0
	}
}

//	MARK: UIPresentationController Methods
extension SimplePresentationController {
	
	override func containerViewWillLayoutSubviews() {
		dimmingView.frame = containerView.bounds
		presentedView().frame = containerView.bounds
	}
	
	override func dismissalTransitionWillBegin() {
		if let coordinator = presentedViewController.transitionCoordinator() {
			coordinator.animateAlongsideTransition({ context in
				self.dimmingView.alpha = 0.0
				}, completion: nil)
		} else {
			dimmingView.alpha = 0.0
		}
	}
	
	override func presentationTransitionWillBegin() {
		dimmingView.frame = containerView.bounds
		dimmingView.alpha = 0.0
		containerView.insertSubview(dimmingView, atIndex: 0)
		
		if let coordinator = presentedViewController.transitionCoordinator() {
			coordinator.animateAlongsideTransition({ context in
				self.dimmingView.alpha = 1.0
				}, completion: nil)
		} else {
			dimmingView.alpha = 1.0
		}
	}
	
	override func shouldPresentInFullscreen() -> Bool {
		return true
	}
}

//	MARK: UIAdaptivePresentationControllerDelegate Methods
extension SimplePresentationController: UIAdaptivePresentationControllerDelegate {
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .OverFullScreen
	}
}