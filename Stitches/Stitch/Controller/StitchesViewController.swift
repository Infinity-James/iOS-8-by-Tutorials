import UIKit
import Photos

let StitchesAlbumTitle = "Stitches"

let StitchCellReuseIdentifier = "StitchCell"
let CreateNewStitchSegueID = "CreateNewStitchSegue"
let StitchDetailSegueID = "StitchDetailSegue"

class StitchesViewController: UIViewController, PHPhotoLibraryChangeObserver, AssetPickerDelegate , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet private var collectionView: UICollectionView!
	@IBOutlet private var noStitchView: UILabel!
	@IBOutlet private var newStitchButton: UIBarButtonItem!
	
	private var assetThumbnailSize = CGSizeZero
	private var stitches: PHFetchResult!
	private var stitchesCollection: PHAssetCollection!
	
	deinit {
		PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
	}
	
	//	MARK: Convenience Functions
	private func fetchStitchesAlbum() {
		//	we want to find the stitches album if it already exists
		let options = PHFetchOptions()
		options.predicate = NSPredicate(format: "title = %@", StitchesAlbumTitle)
		let collections = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumRegular, options: options)
		
		//	if it does exist, we load the assets from it
		if collections.count > 0 {
			stitchesCollection = collections.firstObject as! PHAssetCollection
			stitches = PHAsset.fetchAssetsInAssetCollection(stitchesCollection, options: nil)
			collectionView.reloadData()
			updateNoStitchView()
		} else {	//	create the album if it doesn't exist
			var assetPlaceholder: PHObjectPlaceholder?
			PHPhotoLibrary.sharedPhotoLibrary().performChanges({
				//	request an album creation
				let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(StitchesAlbumTitle)
				//	get a reference to the placeholder to pull the actual album later
				assetPlaceholder = changeRequest.placeholderForCreatedAssetCollection
			}, completionHandler: { success, error in
				if !success {
					println("Failed to create the album: \(error)")
				}
				
				//	get the album we created
				let collections = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([assetPlaceholder!.localIdentifier], options: nil)
				if collections.count > 0 {
					self.stitchesCollection = collections.firstObject as! PHAssetCollection
					self.stitches = PHAsset.fetchAssetsInAssetCollection(self.stitchesCollection, options: nil)
				}
			})
		}
	}
	
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		PHPhotoLibrary.requestAuthorization { status in
			NSOperationQueue.mainQueue().addOperationWithBlock {
				switch status {
				case .Authorized:
					self.fetchStitchesAlbum()
					PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
				case .Denied: fallthrough
				case .NotDetermined: fallthrough
				case .Restricted:	//	if we're not authorised we show an error
					self.noStitchView.text = "Please grant Stitch photo access in Settings -> Privacy"
					self.noStitchView.hidden = false
					self.newStitchButton.enabled = false
					
					self.showNoAccessAlert()
				}
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// Calculate Thumbnail Size
		let scale = UIScreen.mainScreen().scale
		let cellSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
		assetThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
		collectionView.reloadData()
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		collectionView.reloadData()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)  {
		if segue.identifier == CreateNewStitchSegueID {
			let nav = segue.destinationViewController as! UINavigationController
			let dest = nav.viewControllers[0] as! AssetCollectionsViewController
			dest.delegate = self
			dest.selectedAssets = nil
		} else if segue.identifier == StitchDetailSegueID {
			let dest = segue.destinationViewController as! StitchDetailViewController
			let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)!
			dest.asset = stitches[indexPath.item] as! PHAsset
		}
	}
	
	// MARK: Private
	private func updateNoStitchView() {
		noStitchView.hidden = (stitches == nil || (stitches.count > 0))
	}
	
	private func showNoAccessAlert() {
		let alert = UIAlertController(title: "No Photo Access", message: "Please grant Stitch photo access in Settings -> Privacy", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { _ in
			UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
			return
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	// MARK: AssetPickerDelegate
	func assetPickerDidCancel() {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])  {
		dismissViewControllerAnimated(true, completion: nil)
		
		if selectedAssets.count > 0 {
			//	create a stitch with the selected photos
			StitchHelper.createNewStitchWith(selectedAssets, inCollection: stitchesCollection)
		}
	}
	
	// MARK: UICollectionViewDataSource
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return stitches?.count ?? 0
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StitchCellReuseIdentifier, forIndexPath: indexPath) as! AssetCell
		
		let reuseCount = ++cell.reuseCount
		
		let options = PHImageRequestOptions()
		options.networkAccessAllowed = true
		
		let asset = stitches[indexPath.item] as! PHAsset
		PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: assetThumbnailSize, contentMode: .AspectFill, options: options) { result, info in
			//	if this is still the same cell
			if reuseCount == cell.reuseCount {
				cell.imageView.image = result
			}
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		var thumbsPerRow: Int
		switch collectionView.bounds.size.width {
		case 0..<400:
			thumbsPerRow = 2
		case 400..<800:
			thumbsPerRow = 4
		case 800..<1200:
			thumbsPerRow = 5
		default:
			thumbsPerRow = 3
		}
		let width = collectionView.bounds.size.width / CGFloat(thumbsPerRow)
		return CGSize(width: width,height: width)
	}
	
	// MARK: PHPhotoLibraryChangeObserver
	func photoLibraryDidChange(changeInstance: PHChange!)  {
		NSOperationQueue.mainQueue().addOperationWithBlock {
			if let collectionChanges = changeInstance.changeDetailsForFetchResult(self.stitches) {
				self.stitches = collectionChanges.fetchResultAfterChanges
				
				//	if the collection has been reorganised, or has any change that aren't incremental we relaod the whole collection view
				if collectionChanges.hasMoves || !collectionChanges.hasIncrementalChanges {
					self.collectionView.reloadData()
				//	otherwise we perform incremental changes
				} else {
					self.collectionView.performBatchUpdates({
						if collectionChanges.removedIndexes?.count > 0 {
							self.collectionView.deleteItemsAtIndexPaths(self.indexPathsFromIndexSet(collectionChanges.removedIndexes, section: 0))
						} else if collectionChanges.insertedIndexes?.count > 0 {
							self.collectionView.insertItemsAtIndexPaths(self.indexPathsFromIndexSet(collectionChanges.insertedIndexes, section: 0))
						} else if collectionChanges.changedIndexes?.count > 0 {
							self.collectionView.reloadItemsAtIndexPaths(self.indexPathsFromIndexSet(collectionChanges.changedIndexes, section: 0))
						}
						
						}, completion: nil)
				}
			}
		}
	}
	
	// Create an array of index paths from an index set
	func indexPathsFromIndexSet(indexSet:NSIndexSet, section:Int) -> [NSIndexPath] {
		var indexPaths: [NSIndexPath] = []
		indexSet.enumerateIndexesUsingBlock { i, _ in
			indexPaths.append(NSIndexPath(forItem: i, inSection: section))
		}
		return indexPaths
	}
}
