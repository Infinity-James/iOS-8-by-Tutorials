import UIKit
import Photos

protocol AssetPickerDelegate {
	func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])
	func assetPickerDidCancel()
}

class AssetCollectionsViewController: UITableViewController {
	let AssetCollectionCellReuseIdentifier = "AssetCollectionCell"
	
	// MARK: Variables
	var delegate: AssetPickerDelegate?
	var selectedAssets: SelectedAssets?
	
	private let sectionNames = ["","","Albums"]
	private var userAlbums: PHFetchResult!
	private var userFavorites: PHFetchResult!
	
	// MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		if selectedAssets == nil {
			selectedAssets = SelectedAssets()
		}
		
		PHPhotoLibrary.requestAuthorization { status in
			NSOperationQueue.mainQueue().addOperationWithBlock {
				switch status {
				case .Authorized:
					self.fetchCollections()
					self.tableView.reloadData()
				case .Denied: fallthrough
				case .NotDetermined: fallthrough
				case .Restricted:
					self.showNoAccessAlertAndCancel()
				}
			}
		}
	}
	
	override func viewWillAppear(animated: Bool)  {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		let destination = segue.destinationViewController
			as! AssetsViewController
		// Set up AssetCollectionViewController
	}
	
	// MARK: Private
	private func fetchCollections() {
		userAlbums = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
		userFavorites = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumFavorites, options: nil)
	}
	
	func showNoAccessAlertAndCancel() {
		let alert = UIAlertController(title: "No Photo Permissions", message: "Please grant Stitch photo access in Settings -> Privacy", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
			self.cancelPressed(self)
		}))
		alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
			UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
			return
		}))
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	// MARK: Actions
	@IBAction func donePressed(sender: AnyObject) {
		delegate?.assetPickerDidFinishPickingAssets(selectedAssets!.assets)
	}
	
	@IBAction func cancelPressed(sender: AnyObject) {
		delegate?.assetPickerDidCancel()
	}
	
	// MARK: UITableViewDataSource
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return sectionNames.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch(section) {
		case 0: // Selected Section
			return 1
		case 1: // All Photos + Favorites
			return 1 + (userFavorites?.count ?? 0)
		case 2: // Albums
			return 0 + (userAlbums?.count ?? 0)
		default:
			return 0
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(AssetCollectionCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
		cell.detailTextLabel!.text = ""
		
		// Populate the table cell
		switch indexPath.section {
		case 0:
			cell.textLabel!.text = "Selected"
			cell.detailTextLabel!.text = "\(selectedAssets!.assets.count)"
		case 1:
			if indexPath.row == 0 {
				cell.textLabel!.text = "All Photos"
			} else {
				let favorites = userFavorites[indexPath.row - 1] as! PHAssetCollection
				cell.textLabel!.text = favorites.localizedTitle
				if favorites.estimatedAssetCount != NSNotFound {
					cell.detailTextLabel!.text = "\(favorites.estimatedAssetCount)"
				}
			}
		case 2:
			let album = userAlbums[indexPath.row] as! PHAssetCollection
			cell.textLabel!.text = album.localizedTitle
			if album.estimatedAssetCount != NSNotFound {
				cell.detailTextLabel!.text = "\(album.estimatedAssetCount)"
			}
			break
		default:
			break
		}
		
		return cell
	}
}
