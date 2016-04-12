/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

import UIKit

//	MARK: Country Results Controller Delegate
@objc protocol CountryResultsControllerDelegate {
	optional func searchCountrySelected()
}

//	MARK: Country Results Controller Class
class CountryResultsController: UITableViewController
{
	//	MARK: Properties
	var countries = Country.countries()
	var filteredCountries = NSMutableArray()
	var delegate:CountryResultsControllerDelegate?
	
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.separatorStyle = .None
		
		let nib = UINib(nibName:"CountryTableViewCell",
			bundle:nil)
		tableView.registerNib(nib, forCellReuseIdentifier:"Cell")
	}
}

//	MARK: Search Methods
extension CountryResultsController {
	
	func filterContentForSearchText(searchText: String) {
		filteredCountries.removeAllObjects()
		
		let predicate = NSPredicate(format: "SELF.countryName contains[c] %@", searchText)
		
		let tempArray = self.countries.filteredArrayUsingPredicate(predicate)
		
		filteredCountries = NSMutableArray(array: tempArray)
		
		tableView.reloadData()
	}
	
}

//	MARK: UISearchResultsUpdating Methods
extension CountryResultsController: UISearchResultsUpdating {
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		if !searchController.active {
			return
		}
		
		filterContentForSearchText(searchController.searchBar.text)
	}
}

//	MARK: UITableViewDataSource Methods
extension CountryResultsController {

	// #pragma mark – Table View
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredCountries.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
			var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CountryTableViewCell
			
			let country = filteredCountries[indexPath.row] as! Country
			cell.configureCellForCountry(country)
			cell.selectionStyle = .None
		
			return cell
	}
}

//	MARK: UITableViewDelegate Methods
extension CountryResultsController {
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if (delegate?.searchCountrySelected != nil) {
			delegate?.searchCountrySelected!()
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 246.0
	}
}