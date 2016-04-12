//
//  TraitOverrideViewController.swift
//  KhromaPal
//
//  Created by James Valaitis on 11/06/2015.
//  Copyright (c) 2015 RayWenderlich. All rights reserved.
//

import UIKit

class TraitOverrideViewController: UIViewController {
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		
		let traitOverride: UITraitCollection? = size.width > 414.0 ? UITraitCollection(horizontalSizeClass: .Regular) : nil
		setOverrideTraitCollection(traitOverride, forChildViewController: childViewControllers[0] as! UIViewController)
	}
}
