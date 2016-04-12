/*
* Copyright (c) 2015 Razeware LLC
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

//	MARK: Watch View Class
@IBDesignable
class WatchView: UIView {
	
	//	MARK: Properties
	
	///	The seconds can be represented as a hand (`true`), or a ring (`false`).
	@IBInspectable var enableClockSecondHand: Bool = false {
		didSet {
			updateLayerProperties()
		}
	}
	///	The background can be a colour (`true`), or an image (`false`).
	@IBInspectable var enableColorBackground: Bool = false {
		didSet {
			updateLayerProperties()
		}
	}
	///	Base colour layer of the watch.
	private var backgroundLayer = CAShapeLayer()
	///	Base image layer of the watch.
	private var backgroundImageLayer = CAShapeLayer()
	///	A layer that can work to count the seconds.
	private var ringLayer = CAShapeLayer()
	///	A layer for the second hand
	private var secondHandLayer: CAShapeLayer?
	///	A layer for the minute hand.
	private var minuteHandLayer: CAShapeLayer?
	///	A layer for the hour hand.
	private var hourHandLayer: CAShapeLayer?
	///	Changes the colour of the second hand.
	@IBInspectable var secondHandColour: UIColor = UIColor.redColor()
	///	Changes the colour of the minute hand.
	@IBInspectable var minuteHandColour: UIColor = UIColor.whiteColor()
	///	Changes the colour of the minute hand.
	@IBInspectable var hourHandColour: UIColor = UIColor.whiteColor()
	///	The thickness of the ring that indicates seconds.
	@IBInspectable var ringThickness: CGFloat = 2.0
	///	The colour of the ring indicating seconds.
	@IBInspectable var ringColour: UIColor = UIColor.blueColor()
	///	The progress of the second ring
	@IBInspectable var ringProgress: CGFloat = 45.0 / 60.0 {
		didSet {
			updateLayerProperties()
		}
	}
	///	Changes the colour of the background layer for the watch.
	@IBInspectable var backgroundLayerColour: UIColor = UIColor.darkGrayColor() {
		didSet {
			updateLayerProperties()
		}
	}
	///
	@IBInspectable var backgroundImage: UIImage? {
		didSet {
			updateLayerProperties()
		}
	}
	///	Line width of circular frame for watch.
	@IBInspectable var lineWidth: CGFloat = 1.0
	
	//	MARK: Analogue Watch Layers
	
	private func layoutWatchRingLayer() {
		if ringLayer.path != nil {
			if ringProgress == 0 {
				ringLayer.strokeEnd = 0.0
			}
		} else {
			layer.addSublayer(ringLayer)
			let deltaX = ringThickness / 2.0
			let rect = CGRectInset(bounds, deltaX, deltaX)
			let path = UIBezierPath(ovalInRect: rect)
			ringLayer.transform = CATransform3DMakeRotation(CGFloat(-M_PI / 2.0), 0.0, 0.0, 1.0)
			ringLayer.strokeColor = ringColour.CGColor
			ringLayer.path = path.CGPath
			ringLayer.fillColor = nil
			ringLayer.lineWidth = ringThickness
			ringLayer.strokeStart = 0.0
		}
		
		ringLayer.strokeEnd = ringProgress / 60.0
		ringLayer.frame = layer.bounds
	}
	
	func layoutSecondHandLayer() {
		if secondHandLayer == nil {
			secondHandLayer = createClockHand(CGPoint(x: 0.5, y: 1.0), handLength: 20.0, handWidth: 4.0, handAlpha: 1.0, handColour: secondHandColour)
			layer.addSublayer(secondHandLayer)
		}
	}
	
	func layoutMinuteHandLayer() {
		if minuteHandLayer == nil {
			minuteHandLayer = createClockHand(CGPoint(x: 0.5, y: 1.0), handLength: 26.0, handWidth: 7.0, handAlpha: 1.0, handColour: minuteHandColour)
			layer.addSublayer(minuteHandLayer)
		}
	}
	
	func layoutHourHandLayer() {
		if hourHandLayer == nil {
			hourHandLayer = createClockHand(CGPoint(x: 0.5, y: 1.0), handLength: 52.0, handWidth: 7.0, handAlpha: 1.0, handColour: hourHandColour)
			layer.addSublayer(hourHandLayer)
		}
	}
	
	//	MARK: Animation Functions
	func animateAnalogClock() {
	}
	
	//	MARK: Background Layers
	
	func layoutBackgroundLayer() {
		//	set up background layer if it's not set up
		if backgroundLayer.path == nil {
			layer.addSublayer(backgroundLayer)
			
			let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)
			let path = UIBezierPath(ovalInRect: rect)
			
			backgroundLayer!.path = path.CGPath
			backgroundLayer!.fillColor = backgroundLayerColour.CGColor
			backgroundLayer!.lineWidth = lineWidth
		}
		
		backgroundLayer?.frame = layer.bounds
	}
	
	func layoutBackgroundImageLayer() {
		if backgroundImageLayer.mask == nil {
			let maskLayer = CAShapeLayer()
			let deltaX = lineWidth + 3.0
			let insetBounds = CGRectInset(bounds, deltaX, deltaX)
			let innerPath = UIBezierPath(ovalInRect: insetBounds)
			maskLayer.path = innerPath.CGPath
			maskLayer.fillColor = UIColor.blackColor().CGColor
			maskLayer.frame = bounds
			
			backgroundImageLayer.mask = maskLayer
			backgroundImageLayer.frame = bounds
			backgroundImageLayer.contentsGravity = kCAGravityResizeAspectFill
			layer.addSublayer(backgroundImageLayer)
		}
	}
	
	//	MARK: Clock Creations
	
	func createClockFace() {
		
		layoutBackgroundLayer()
		layoutBackgroundImageLayer()
		createAnalogClock()
		updateLayerProperties()
	}
	
	func createAnalogClock() {
		layoutMinuteHandLayer()
		layoutHourHandLayer()
		
		if enableClockSecondHand == true {
			layoutSecondHandLayer()
		} else {
			layoutWatchRingLayer()
		}
	}
	
	//	MARK: Helper Methods
	
	private func createClockHand(anchorPoint: CGPoint, handLength: CGFloat, handWidth: CGFloat, handAlpha: CGFloat, handColour: UIColor) -> CAShapeLayer {
		let handLayer = CAShapeLayer()
		let path = UIBezierPath()
		
		path.moveToPoint(CGPoint(x: 1.0, y: handLength))
		path.addLineToPoint(CGPoint(x: 1.0, y: center.y))
		handLayer.bounds = CGRect(x: 0.0, y: 0.0, width: 1.0, height: center.y)
		handLayer.anchorPoint = anchorPoint
		handLayer.position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
		handLayer.lineWidth = handWidth
		handLayer.opacity = Float(handAlpha)
		handLayer.strokeColor = handColour.CGColor
		handLayer.path = path.CGPath
		handLayer.lineCap = kCALineCapRound
		
		return handLayer
	}
	
	//	MARK: Initialisation
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
	}
	
	//	MARK: Property Observation Functions
	
	func updateLayerProperties() {
		if ringLayer.path != nil {
			ringLayer.strokeEnd = ringProgress / 60.0
		}
		
		setHideImageBackground(enableColorBackground)
		setHideSecondClockHand(!enableClockSecondHand)
		setHideRingLayer(enableClockSecondHand)
		
		if backgroundLayer.path != nil {
			backgroundLayer.fillColor = backgroundLayerColour.CGColor
		}
		
		if let image = backgroundImage where backgroundImageLayer.mask != nil {
			backgroundImageLayer.contents = image.CGImage
		}
	}
	
	private func setHideImageBackground(willHide: Bool) {
		backgroundImageLayer.hidden = willHide
	}
	
	private func setHideSecondClockHand(willHide: Bool) {
		secondHandLayer?.hidden = willHide
	}
	
	func setHideRingLayer(willHide: Bool) {
		ringLayer.hidden = willHide
	}
	
	//	MARK: Time Management
	func startTimeWithTimeZone(timezone: String) {
	}
	
	func endTime() {
	}
	
	//	MARK: View Lifecycle
	
	override func layoutSubviews() {
		super.layoutSubviews()
		createClockFace()
	}
}