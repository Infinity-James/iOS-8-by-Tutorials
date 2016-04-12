//
//  WeatherStatus.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import Foundation
import UIKit

//  MARK: Weather Status Type Enum

enum WeatherStatusType: String {
	/**	Indicates cloudy weather.	*/
	case Cloud = "Cloud"
	/**	Indicates possibility of lightning.	*/
	case Lightning = "Lightning"
	/**	Indicates sunny weather.	*/
	case Sun = "Sun"
	
	/**	An image representative of the weather status type.	*/
	var image: UIImage {
		return UIImage(named: self.rawValue)!
	}
}

//	MARK: Weather Status Struct

struct WeatherStatus {
	/**	The temperature of the weather.	*/
	private(set) var temperature: Int
	/**	The type of weather.	*/
	private(set) var weatherType: WeatherStatusType
	
	/**
		Initialises a new weather status object.
		
		:param:	temperature		The temperature of the weather.
		:param:	weatherType		The type of weather.
	
		:returns:	A newly initialised WeatherStatus struct.
	*/
	init(temperature: Int, weatherType: WeatherStatusType) {
		self.temperature = temperature
		self.weatherType = weatherType
	}
}