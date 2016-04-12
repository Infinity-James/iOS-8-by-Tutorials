//
//  MasterViewController.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Master View Controller Class
class MasterViewController: UITableViewController {
	
	//	MARK: Constants
	
	private let CityCellReuseIdentifier = "CityCell"
	private let DetailSegueIdentifier = "showDetail"
	
	//	MARK: Properties
	
	/**	The detail view controller that accompanies this master view controller.	*/
	var detailViewController: DetailViewController?
	/**	All weather data to be displayed.	*/
	let weatherData = WeatherData()
	
	//	MARK: Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == DetailSegueIdentifier {
			if let indexPath = tableView.indexPathForSelectedRow(),
				let detailViewController = (segue.destinationViewController as? UINavigationController)?.topViewController as? DetailViewController {
					detailViewController.cityWeather = weatherData.cities[indexPath.row]
					detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
			}
		}
	}
	
	//	MARK: View Lifecycle
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			clearsSelectionOnViewWillAppear = false
			preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
		
		prepareNavigationBarAppearance()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let splitViewController = self.splitViewController {
			let viewControllers = splitViewController.viewControllers
			detailViewController = viewControllers.last?.topViewController as? DetailViewController
			if let detailViewController = detailViewController {
				detailViewController.cityWeather = weatherData.cities.first
			}
		}
		
		title = "Cities"
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 100.0
	}
}

//	MARK: Master View Controller - UITableViewDataSource Methods

extension MasterViewController {
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(CityCellReuseIdentifier, forIndexPath: indexPath) as! CityTableViewCell
		
		let city = weatherData.cities[indexPath.row]
		cell.cityWeather = city
		
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return weatherData.cities.count
	}
}

//	MARK: Master View Controller - View Configuration
extension MasterViewController {
	private func prepareNavigationBarAppearance() {
		let font = UIFont(name: "HelveticaNeue-Light", size: 30.0)!
		let regularVertical = UITraitCollection(verticalSizeClass: .Regular)
		let compactVertical = UITraitCollection(verticalSizeClass: .Compact)
		
		UINavigationBar.appearanceForTraitCollection(regularVertical).titleTextAttributes = [NSFontAttributeName: font]
		UINavigationBar.appearanceForTraitCollection(compactVertical).titleTextAttributes = [NSFontAttributeName: font.fontWithSize(20.0)]
	}
}