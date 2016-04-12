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

import UIKit

//	MARK: Country List View Controller Class
class CountryListViewController: UITableViewController {
	
	//	MARK: Properties
	var countryDetailViewController: CountryDetailViewController?
	var countries = Country.countries()
	var searchController: UISearchController?
	
	//	MARK: Initialisation
	override func awakeFromNib() {
		super.awakeFromNib()
		self.clearsSelectionOnViewWillAppear = false
		self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
	}
	
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Countries"
		
		if let controllers = splitViewController?.viewControllers {
			countryDetailViewController = controllers[controllers.endIndex - 1].topViewController as? CountryDetailViewController
		}
		
		let country = countries[0] as! Country
		countryDetailViewController?.country = country
		
		addSearchBar()
	}
	
	//	MARK: Segues
	override func prepareForSegue(segue: UIStoryboardSegue,
		sender: AnyObject?) {
			
			if segue.identifier == "showDetail" {
				
				let country: Country
				
				if let searchController = searchController where searchController.active {
					let resultsController = searchController.searchResultsController as! CountryResultsController
					let indexPath = resultsController.tableView.indexPathForSelectedRow()!
					country = resultsController.filteredCountries[indexPath.row] as! Country
				} else {
					let indexPath = self.tableView.indexPathForSelectedRow()
					country = countries[indexPath!.row] as! Country
				}
				
				((segue.destinationViewController as? UINavigationController)?.topViewController as? CountryDetailViewController)?.country = country
			}
	}
}

//	MARK: Search
extension CountryListViewController {
	
	func addSearchBar() {
		let resultsController = CountryResultsController()
		resultsController.countries = countries
		resultsController.delegate = self
		
		searchController = UISearchController(searchResultsController: resultsController)
		searchController!.searchResultsUpdater = resultsController
		searchController!.searchBar.frame = CGRect(origin: searchController!.searchBar.frame.origin,
													size: CGSize(width: CGRectGetWidth(searchController!.searchBar.frame), height: 44.0))
		tableView.tableHeaderView = searchController!.searchBar
		definesPresentationContext = true
		
	}
}

//	MARK: CountryResultsControllerDelegate Methods
extension CountryListViewController: CountryResultsControllerDelegate {
	
	func searchCountrySelected() {
		performSegueWithIdentifier("showDetail", sender: nil)
	}
	
}

//	MARK: UITableViewDataSource Methods
extension CountryListViewController {
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return countries.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
			
			var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CountryTableViewCell
			
			let country = countries[indexPath.row]as! Country
			cell.configureCellForCountry(country)
		
			return cell
	}
}

//	MARK: UITableViewDelegate Methods
extension CountryListViewController {

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let country = countries[indexPath.row] as! Country
		countryDetailViewController?.country = country
	}
}
