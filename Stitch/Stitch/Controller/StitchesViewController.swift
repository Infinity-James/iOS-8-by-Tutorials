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
		// Unregister observer
	}
	
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
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
		
		// Create new Stitch
	}
	
	// MARK: UICollectionViewDataSource
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return stitches?.count ?? 0
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StitchCellReuseIdentifier, forIndexPath: indexPath) as! AssetCell
		
		// Configure the Cell
		
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
		// Respond to changes
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
