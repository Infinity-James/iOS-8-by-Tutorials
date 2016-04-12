//
//  DailyWeather.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Daily Weather Class

class DailyWeather {
	/**	A property that allows for formatting a day name date.	*/
	private let dayNameDateFormatter = NSDateFormatter()
	/**	The date of the day's weather.	*/
	private(set) var date: NSDate
	/**	The day's weather status.	*/
	private(set) var weatherStatus: WeatherStatus
	/**	The day's name.	*/
	var dayName: String {
		dayNameDateFormatter.dateFormat = "E"
		return dayNameDateFormatter.stringFromDate(date)
	}
	
	/**
		Initialises a new DailyWeather object.
		
		:param:	date			The date of the day's weather.
		:param:	weatherStatus	The status of the day's weather.
	
		:returns:	A newly initialised DailyWeather object.
	*/
	init(date: NSDate, weatherStatus: WeatherStatus) {
		self.date = date
		self.weatherStatus = weatherStatus
	}
}