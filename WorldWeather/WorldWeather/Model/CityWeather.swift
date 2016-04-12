//
//  CityWeather.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import Foundation
import UIKit

//	MARK: City Weather Class

@objc class CityWeather {
	/**	The name of the city.	*/
	private(set) var name: String
	/**	An array of object representing the weather of specific days.	*/
	private(set) var weather: [DailyWeather]
	/**	An image of the city.	*/
	var cityImage: UIImage? {
		return UIImage(named: name)
	}
	
	/**
		Initialises a new CityWeather object.
		
		:param:	name		The name of the city.
		:param:	weather		An array of the weather of the city for various days.
		
		:returns:	A newly initialised CityWeather object.
	*/
	init(name: String, weather: [DailyWeather]) {
		self.name = name
		self.weather = weather
	}
}