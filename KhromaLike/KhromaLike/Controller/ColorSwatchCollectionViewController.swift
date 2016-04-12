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
import QuartzCore

let reuseIdentifier = "ColorSwatchCell"

// MARK: ColorSwatchCollectionViewController Methods
class ColorSwatchCollectionViewController: UICollectionViewController, ColorSwatchSelector {
	
	//	MARK: Properties
	var swatchList: ColorSwatchList?
	var swatchSelectionDelegate: ColorSwatchSelectionDelegate?
	var currentCellContentTransform = CGAffineTransformIdentity
	
	//	MARK: UIContentContainer Methods
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		
		let targetTransform = coordinator.targetTransform()
		let inverseTransform = CGAffineTransformInvert(targetTransform)
		
		//
		coordinator.animateAlongsideTransition(nil, completion: { _ in
			//	apply the inverse transform to the collection view's layer
			self.view.layer.transform =  CATransform3DConcat(self.view.layer.transform, CATransform3DMakeAffineTransform(inverseTransform))
			
			//	update the bounds of the view (switch width and height for 90º rotation
			if abs(atan2(Double(targetTransform.b), Double(targetTransform.a)) / M_PI) < 0.9 {
				self.view.bounds = CGRect(x: 0.0, y: 0.0, width: CGRectGetHeight(self.view.bounds), height: CGRectGetWidth(self.view.bounds))
			}
			
			//	correct orientation of cells
			self.currentCellContentTransform = CGAffineTransformConcat(self.currentCellContentTransform, targetTransform)
			UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: nil, animations: {
				for cell in self.collectionView?.visibleCells() as! [UICollectionViewCell] {
					cell.contentView.transform = self.currentCellContentTransform
				}
			}, completion: nil)
		})
	}
	
	//	MARK: View Lifecycle
	override func viewWillAppear(animated: Bool) {
		if swatchList == nil {
			swatchList = ColorSwatchList()
			collectionView(collectionView!, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
		}
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
			let minDimension = min(CGRectGetHeight(view.bounds), CGRectGetWidth(view.bounds))
			let newItemSize = CGSize(width: minDimension, height: minDimension)
			if flowLayout.itemSize != newItemSize {
				flowLayout.itemSize = newItemSize
				flowLayout.invalidateLayout()
			}
		}
	}
}

// MARK: UICollectionViewDataSource Methods
extension ColorSwatchCollectionViewController {
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return swatchList?.colorSwatches.count ?? 0
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
		// Configure the cell
		if let swatchCell = cell as? ColorSwatchCollectionViewCell,
			let swatch = swatchList?.colorSwatches[indexPath.item] {
				swatchCell.resetCell(swatch)
		}
		return cell
	}
}

// MARK: UICollectionViewDelegate Methods
extension ColorSwatchCollectionViewController {
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		if let swatch = swatchList?.colorSwatches[indexPath.item] {
			swatchSelectionDelegate?.didSelect(swatch, sender: self)
		}
	}
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		cell.contentView.transform = currentCellContentTransform
	}
}

