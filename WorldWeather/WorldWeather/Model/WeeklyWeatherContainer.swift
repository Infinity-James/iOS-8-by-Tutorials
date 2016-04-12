//
//  WeeklyWeatherContainer.swift
//  WorldWeather
//
//  Created by James Valaitis on 09/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

@objc protocol WeeklyWeatherContainer {
	var dailyWeather: [DailyWeather] { get set }
}