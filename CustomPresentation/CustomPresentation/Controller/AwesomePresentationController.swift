//
//  AwesomePresentationController.swift
//  CustomPresentation
//
//  Created by James Valaitis on 22/06/2015.
//  Copyright (c) 2015 Fresh App Factory. All rights reserved.
//

import UIKit

//	MARK: Awesome Presentation Controller Class
class AwesomePresentationController: UIPresentationController {
   
	//	MARK: Properties
	let dimmingView = UIView()
	let flagImageView = UIImageView(frame: CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: 160.0, height: 93.0)))
	var selectionObject: SelectionObject? {
		didSet {
			if let selectionObject = selectionObject {
				flagImageView.image = UIImage(named: selectionObject.country.imageName)!
				flagImageView.frame = selectionObject.originalCellPosition
			}
		}
	}
	var isAnimating = false
	
	//	MARK: Initialisation
	override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
		super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
		
		dimmingView.backgroundColor = UIColor.clearColor()
		flagImageView.contentMode = .ScaleAspectFill
		flagImageView.clipsToBounds = true
		flagImageView.layer.cornerRadius = 4.0
	}
}

//	MARK: Convenience & Helper Methods
extension AwesomePresentationController {
	private func animateFlagToPresentedPosition(presentedPosition: Bool, withBounce bounce: Bool = false) {
		
		let animation = { self.moveFlagToPresentedPosition(presentedPosition) }
		let completion = { self.isAnimating = false }
		
		if bounce {
			UIView.animateWithDuration(0.7, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: animation, completion: { success in completion() })
		} else {
			let coordinator = presentedViewController.transitionCoordinator()!
			coordinator.animateAlongsideTransition({ _ in
				animation()
				}, completion: { _ in
					completion()
			})
		}
	}
	
	private func moveFlagToPresentedPosition(presentedPosition: Bool) {
		let containerFrame = containerView.frame
		
		if presentedPosition {
			scaleAndPositionFlag()
		} else {
			flagImageView.frame = selectionObject!.originalCellPosition
		}
	}
	
	private func scaleAndPositionFlag() {
		var flagFrame = flagImageView.frame
		let containerFrame = containerView.frame
		
		var originYMultiplier: CGFloat = 0.0
		let cellSize = selectionObject!.originalCellPosition.size
		
		if containerFrame.width > containerFrame.height {
			//	smaller flag
			flagFrame.size.width = cellSize.width * 1.5
			flagFrame.size.height = cellSize.height * 1.5
			originYMultiplier = 1/4
		} else {
			flagFrame.size.width = cellSize.width * 1.8
			flagFrame.size.height = cellSize.height * 1.8
			originYMultiplier = 1/3
		}
		
		//	horizontally centre position vertically with the y offset
		flagFrame.origin.x = (containerFrame.width / 2.0) - (flagFrame.width / 2.0)
		flagFrame.origin.y = (containerFrame.height * originYMultiplier) - (flagFrame.height / 2.0)
		
		flagImageView.frame = flagFrame
	}
}

//	MARK: UIPresentationController Methods
extension AwesomePresentationController {
	
	override func containerViewWillLayoutSubviews() {
		dimmingView.frame = containerView.bounds
		presentedView().frame = containerView.bounds
	}
	
	override func dismissalTransitionWillBegin() {
		super.dismissalTransitionWillBegin()
		
		isAnimating = true
		animateFlagToPresentedPosition(false, withBounce: true)
	}
	
	override func frameOfPresentedViewInContainerView() -> CGRect {
		return containerView.bounds
	}
	
	override func presentationTransitionWillBegin() {
		super.presentationTransitionWillBegin()
		
		isAnimating = true
		moveFlagToPresentedPosition(false)
		
		dimmingView.addSubview(flagImageView)
		containerView.addSubview(dimmingView)
		
		animateFlagToPresentedPosition(true, withBounce: true)
	}
	
	override func shouldPresentInFullscreen() -> Bool {
		return true
	}
}

//	MARK: UIAdaptivePresentationControllerDelegate Methods
extension AwesomePresentationController: UIAdaptivePresentationControllerDelegate {
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .OverFullScreen
	}
}
