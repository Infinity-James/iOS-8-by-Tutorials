//
//  DetailViewController.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import Foundation
import UIKit

//	MARK: Detail View Controller Class
class DetailViewController: UIViewController {
	/**	An image view holding an icon representing the weather.	*/
	@IBOutlet weak var weatherIconImageView: UIImageView!
	/**	The city weather being currently displayed.*/
	var cityWeather: CityWeather? {
		didSet {
			if isViewLoaded() {
				
			}
		}
	}
	
	//	MARK: View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureView()
		provideDataToChildViewControllers()
		
		navigationItem.leftItemsSupplementBackButton = true
		navigationItem.hidesBackButton = false
		
		configureTraitOverrideForSize(view.bounds.size)
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		configureTraitOverrideForSize(size)
	}
}

//	MARK: Detail View Controller - Utility
extension DetailViewController {
	private func configureView() {
		if let cityWeather = cityWeather {
			title = cityWeather.name
			weatherIconImageView.image = cityWeather.weather.first?.weatherStatus.weatherType.image
		}
	}
	
	private func  provideDataToChildViewControllers() {
		for childVC in childViewControllers {
			if let cityWeatherContainer = childVC as? CityWeatherContainer {
				cityWeatherContainer.cityWeather = cityWeather
			}
		}
	}
}

//	MARK: Detail View Controller - Trait Collection
extension DetailViewController {
	private func configureTraitOverrideForSize(size: CGSize) {
		var traitOverride: UITraitCollection?
		if size.height < 1000 {
			traitOverride = UITraitCollection(verticalSizeClass: .Compact)
		}
		
		for childVC in childViewControllers as! [UIViewController] {
			setOverrideTraitCollection(traitOverride, forChildViewController: childVC)
		}
	}
}