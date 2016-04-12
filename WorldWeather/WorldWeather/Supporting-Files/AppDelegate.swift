//
//  AppDelegate.swift
//  WorldWeather
//
//  Created by James Valaitis on 03/05/2015.
//  Copyright (c) 2015 &Beyond. All rights reserved.
//

import UIKit

//	MARK: App Delegate Class
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		let splitViewController = self.window?.rootViewController as? UISplitViewController
		let navigationController = splitViewController?.viewControllers[splitViewController!.viewControllers.count - 1] as? UINavigationController
		navigationController?.topViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
		splitViewController?.delegate = self
        return true
    }
}

//	MARK: App Delegate - Split View Controller Delegate
extension AppDelegate: UISplitViewControllerDelegate {
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
		if let navigationController = secondaryViewController as? UINavigationController,
			let detailController = navigationController.topViewController as? DetailViewController
			where detailController.cityWeather == nil {
			return true
		}
		return false
	}
}