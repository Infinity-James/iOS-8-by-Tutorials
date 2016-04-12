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

//	MARK: Country Detail View Controller Class

class CountryDetailViewController: UIViewController {
	
	//	MARK: Proprties
	@IBOutlet var flagImageView: UIImageView!
	@IBOutlet var quizQuestionLabel: UILabel!
	@IBOutlet var answer1Button: UIButton!
	@IBOutlet var answer2Button: UIButton!
	@IBOutlet var answer3Button: UIButton!
	@IBOutlet var answer4Button: UIButton!
	
	var masterPopoverController: UIPopoverController? = nil
	var country: Country? {
		didSet {
			configureView()
			
			if masterPopoverController != nil {
				masterPopoverController!.dismissPopoverAnimated(true)
			}
		}
	}
	
	//	MARK: Auto Layout
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		quizQuestionLabel.preferredMaxLayoutWidth = view.bounds.size.width - 40
	}
	
	//	MARK: View Configuration
	
	func addCountryListButton() {
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			var countriesButton: UIBarButtonItem =
			UIBarButtonItem(title: "Countries",
				style: UIBarButtonItemStyle.Plain,
				target: self.splitViewController,
				action: "toggleMasterVisible:")
			
			navigationItem.leftBarButtonItem = countriesButton
		}
	}
	
	func configureView() {
		if country != nil {
			self.title = country!.countryName;
			
			if flagImageView != nil {
				var image: UIImage = UIImage(named: country!.imageName)!;
				flagImageView.image = image;
			}
			
			if quizQuestionLabel != nil {
				quizQuestionLabel.text = country!.quizQuestion;
			}
			
			if answer1Button != nil {
				answer1Button.setTitle(country!.quizAnswers[0],forState:UIControlState.Normal)
			}
			
			if answer2Button != nil {
				answer2Button.setTitle(country!.quizAnswers[1], forState:UIControlState.Normal)
			}
			
			if answer3Button != nil {
				answer3Button.setTitle(country!.quizAnswers[2], forState:UIControlState.Normal)
			}
			
			if answer4Button != nil {
				answer4Button.setTitle(country!.quizAnswers[3],forState:UIControlState.Normal)
			}
		}
		
		let detailsButton: UIBarButtonItem = UIBarButtonItem(title: "Facts", style: .Plain, target: self, action: "displayFacts:")
		navigationItem.rightBarButtonItem = detailsButton
	}
	
	//	MARK: View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if splitViewController!.displayMode ==
			UISplitViewControllerDisplayMode.PrimaryHidden {
				
				addCountryListButton()
		}
		
		configureView()
	}
	
}

//	MARK: Quiz & Fact Methods
extension CountryDetailViewController {
	
	func displayFacts(sender: UIBarButtonItem) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		
		let contentViewController = storyboard.instantiateViewControllerWithIdentifier("CountryPopoverViewController") as! CountryPopoverViewController
		contentViewController.country = country
		contentViewController.modalPresentationStyle = .Popover
		
		if let detailPopover = contentViewController.popoverPresentationController {
			detailPopover.barButtonItem = sender
			detailPopover.permittedArrowDirections = .Any
			detailPopover.delegate = self
		}
		
		presentViewController(contentViewController, animated: true) {}
		
	}
	
	@IBAction func quizAnswerButtonPressed(sender: UIButton) {
		let buttonTitle = sender.titleLabel?.text
		var message = ""
		if buttonTitle == country!.correctAnswer {
			message = "You answered correctly."
		} else {
			message = "WRONG. Super wrong dude."
		}
		
		var alert = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
		alert.addAction(UIAlertAction(title: "Okay", style: .Default) { alertAction in
			println("Tapped Okay.")
		})
		
		alert.popoverPresentationController?.sourceView = view
		alert.popoverPresentationController?.sourceRect = sender.frame
		
		presentViewController(alert, animated: true) {}
	}
}

//	MARK: UIPopoverPresentationControllerDelegate Methods
extension CountryDetailViewController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
		let navController = UINavigationController(rootViewController: controller.presentedViewController)
		return navController
	}
}

//	MARK: UISplitViewControllerDelegate Methods
extension CountryDetailViewController: UISplitViewControllerDelegate {
	func splitViewController(svc: UISplitViewController,
		willChangeToDisplayMode displayMode:
		UISplitViewControllerDisplayMode) {
			
			if displayMode ==
				UISplitViewControllerDisplayMode.AllVisible {
					navigationItem.leftBarButtonItem = nil;
			} else {
				let barButtonItem = svc.displayModeButtonItem()
				navigationItem.leftBarButtonItem = barButtonItem
			}
	}
	
	func splitViewController(splitViewController: UISplitViewController,
		collapseSecondaryViewController secondaryViewController: UIViewController!,
		ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool  {
			
			return true
	}
}