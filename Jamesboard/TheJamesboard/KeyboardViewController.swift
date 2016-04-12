//
//  KeyboardViewController.swift
//  TheJamesboard
//
//  Created by James Valaitis on 24/07/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Keyboard View Controller Class
class KeyboardViewController: UIInputViewController {

	//	MARK: Properties
    @IBOutlet var nextKeyboardButton: UIButton!
	
	//	MARK: UIInputViewController Methods
	
    override func textWillChange(textInput: UITextInput) {
    }

    override func textDidChange(textInput: UITextInput) {
    
        var textColor: UIColor
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }
	
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Perform custom UI setup here
		self.nextKeyboardButton = UIButton.buttonWithType(.System) as! UIButton
		
		self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
		self.nextKeyboardButton.sizeToFit()
		self.nextKeyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
		
		self.view.addSubview(self.nextKeyboardButton)
		
		var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
		var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
		self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])
	}
}
