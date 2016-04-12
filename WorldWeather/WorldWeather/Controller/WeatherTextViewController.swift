//
//  WeatherTextViewController.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Weather Text View Controller Class
class WeatherTextViewController: UIViewController, CityWeatherContainer {
	//	MARK: IBOutlets
	@IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	
	//	MARK: Properties
	var cityWeather: CityWeather? {
		didSet {
			if isViewLoaded() {
				configureView()
			}
			provideDataToChildViewControllers()
		}
	}
	
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureView()
		
		let traitOverride = UITraitCollection(horizontalSizeClass: .Compact)
		for childVC in childViewControllers as! [UIViewController] {
			setOverrideTraitCollection(traitOverride, forChildViewController: childVC)
		}
	}
}

//	MARK: Weather Text View Controller - Utility
extension WeatherTextViewController {
	private func configureView() {
		if let cityWeather = cityWeather {
			cityNameLabel.text = cityWeather.name
			temperatureLabel.text = "\(cityWeather.weather[0].weatherStatus.temperature)"
		}
	}
	
	private func provideDataToChildViewControllers() {
		for childVC in childViewControllers {
			if let weeklyWeatherContainer = childVC as? WeeklyWeatherContainer,
				let weeklyWeather = cityWeather?.weather {
					weeklyWeatherContainer.dailyWeather = weeklyWeather
			}
		}
	}
}