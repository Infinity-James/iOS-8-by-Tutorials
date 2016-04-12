//
//  WeatherData.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Weather Data Class
class WeatherData {
	/**	An array of cities and thei weather.	*/
	private(set) var cities = [CityWeather]()
	
	/**
		Initialises a new WeatherData object.
		
		:param:	weatherDataPropertyList		A .plist with weather data.
		
		:returns:	A newly initialised WeatherData object.
	*/
	init(plistNamed weatherDataPlistName: String) {
		self.cities = self.loadWeatherData(plistNamed: weatherDataPlistName)
	}
	
	/**
		Initialises a new WeatherData object with our sample data.
	
		:returns:	A newly initialised WeatherData object.
	*/
	convenience init() {
		self.init(plistNamed:"WeatherData")
	}
}

//	MARK: Weather Data - Data Loading
extension WeatherData {
	private func loadWeatherData(plistNamed weatherDataPlistName: String) -> [CityWeather] {
		var cityWeather = [CityWeather]()
		if let plistFileName = NSBundle.mainBundle().pathForResource(weatherDataPlistName, ofType: "plist"),
			let cityWeatherRoot = NSDictionary(contentsOfFile: plistFileName) as? [String: [NSDictionary]]
		{
			for (name, dailyWeather) in cityWeatherRoot {
				cityWeather.append(CityWeather(name: name, weatherArray: dailyWeather))
			}
		}
		return cityWeather
	}
}

//	MARK: City Weather - Convenience Initialiser
extension CityWeather {
	private convenience init(name: String, weatherArray: [NSDictionary]) {
		var dailyWeather = [DailyWeather]()
		for dictionary in weatherArray {
			dailyWeather.append(DailyWeather(weatherDictionary: dictionary))
		}
		self.init(name: name, weather: dailyWeather)
	}
}

//	MARK: Daily Weather - Convenience Initialiser
extension DailyWeather {
	private convenience init(weatherDictionary: NSDictionary) {
		let weatherStatus = WeatherStatus(weatherDictionary: weatherDictionary)
		self.init(date: weatherDictionary["date"] as! NSDate, weatherStatus: weatherStatus)
	}
}

//	MARK: Weather Status - Convenienve Initialiser
extension WeatherStatus {
	private init(weatherDictionary: NSDictionary) {
		let dictionaryType = weatherDictionary["type"] as! String
		self.init(temperature: weatherDictionary["temperature"] as! Int, weatherType: WeatherStatusType(rawValue: dictionaryType)!)
	}
}