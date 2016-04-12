//
//  DailyWeatherCollectionViewController.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Daily Weather Collection View Controller Class
class DailyWeatherCollectionViewController: UICollectionViewController, WeeklyWeatherContainer {
	/**	An identifier to user to reuse cells.	*/
	private let reuseIdentifier = "DailyWeatherCell"
	/**	An array of objects representing the weather for each day.	*/
	var dailyWeather = [DailyWeather]() {
		didSet {
			collectionView?.reloadData()
		}
	}
}

//	MARK: Daily Weather Collection View Controller - UICollectionViewDataSource
extension DailyWeatherCollectionViewController {
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dailyWeather.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
		return cell
	}
}