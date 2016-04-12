//
//  CityTableViewCell.swift
//  WorldWeather
//
//  Created by James Valaitis on 04/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import UIKit

//	MARK: City Table View Cell Class
class CityTableViewCell: UITableViewCell {
	//	MARK: IBOutlets
	@IBOutlet weak var cityImageView: UIImageView!
	@IBOutlet weak var cityNameLabel: UILabel!
	
	//	MARK: Properties
	var cityWeather: CityWeather? {
		didSet {
			configureCell()
		}
	}
}

//	MARK: City Table View Cell - Utility Methods
extension CityTableViewCell {
	private func configureCell() {
		cityImageView.image = cityWeather?.cityImage
		cityNameLabel.text = cityWeather?.name
	}
}