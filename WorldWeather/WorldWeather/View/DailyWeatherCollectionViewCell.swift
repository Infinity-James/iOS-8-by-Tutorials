//
//  DailyWeatherCollectionViewCell.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Daily Weather Collection View Cell Class
class DailyWeatherCollectionViewCell: UICollectionViewCell {
	//	MARK: IBOutlets
	@IBOutlet weak var dayNameLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var weatherIconImageView: UIImageView!
	
	//	MARK: Properties
	var dailyWeather: DailyWeather? {
		didSet {
			configureView()
		}
	}
}

//	MARK: Daily Weather Collection View Cell - Utility Methods
extension DailyWeatherCollectionViewCell {
	private func configureView() {
		if let dailyWeather = dailyWeather {
			dayNameLabel.text = dailyWeather.dayName
			temperatureLabel.text = "\(dailyWeather.weatherStatus.temperature)"
			weatherIconImageView.image = dailyWeather.weatherStatus.weatherType.image
		}
	}
}