//
//  TodayViewController.swift
//  BTC Status
//
//  Created by James Valaitis on 29/06/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import CryptoCurrencyKit
import UIKit
import NotificationCenter

class TodayViewController: CurrencyDataViewController, NCWidgetProviding {
	
	//	MARK: Properties - Constants
	private let lineChartHeight: CGFloat = 98.0
	//	MARK: Properties - Outlets
	@IBOutlet var lineChartHeightConstraint: NSLayoutConstraint!
	@IBOutlet var toggleLineChartButton: UIButton!
	//	MARK: Properties - State
	private var lineChartIsVisible = false {
		didSet {
			lineChartHeightConstraint.constant = lineChartIsVisible ? lineChartHeight : 0.0
		}
	}
	
	//	MARK: View Lifecycle
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		fetchPrices { error in
			if error == nil {
				self.updatePriceLabel()
				self.updatePriceChangeLabel()
				self.updatePriceHistoryLineChart()
			}
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updatePriceHistoryLineChart()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		lineChartHeightConstraint.constant = lineChartIsVisible ? lineChartHeight : 0.0
		
		lineChartView.dataSource = self
		lineChartView.delegate = self
		
		priceLabel.text = "--"
		priceChangeLabel.text = "--"
		
    }
	
	//	MARK: NCWidgetProviding Methods
	func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
		return UIEdgeInsetsZero
	}
	
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
		fetchPrices { error in
			if error == nil {
				self.updatePriceLabel()
				self.updatePriceChangeLabel()
				self.updatePriceHistoryLineChart()
				completionHandler(.NewData)
			} else {
				completionHandler(.NoData)
			}
		}
		
        completionHandler(NCUpdateResult.NewData)
    }
}

//	MARK: Action Methods
extension TodayViewController {
	
	@IBAction func toggleLineChart() {
		lineChartIsVisible = !lineChartIsVisible
		let rotation = lineChartIsVisible ? M_PI : 0.0
		toggleLineChartButton.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
	}
}

//	MARK: JBLineChartViewDataSource Methods
extension TodayViewController {
	override func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return UIColor(red: 0.17, green: 0.49, blue: 0.82, alpha: 1.0)
	}
}