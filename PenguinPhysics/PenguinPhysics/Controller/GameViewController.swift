//
//  GameViewController.swift
//  PenguinPhysics
//
//  Created by Jake Gundersen on 7/23/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

//	MARK: Game View Controller
class GameViewController: UIViewController {
	
	//	MARK: Properties
	var applyForce = false
	let cube: SCNNode
	var force = Float(50.0)
	var sliderJoint = SCNPhysicsSliderJoint()
	let slopeNode = SCNNode()
	let scene = SCNScene(named: "SceneIceRotated.dae")!
	@IBOutlet weak var sceneView: SCNView!
	
	//	MARK: Actions
	@IBAction private func angleSliderMoved(angleSlider: UISlider) {
		var angle = (1.0 - angleSlider.value) * Float(M_PI_4)
		slopeNode.eulerAngles = SCNVector3Make(0.0, 0.0, angle)
	}
	
	@IBAction private func applyForceTapped(applyButton: UIButton) {
		let title = applyForce ? "Apply Force" : "Stop"
		applyButton.setTitle(title, forState: .Normal)
		applyForce = !applyForce
	}
	
	@IBAction private func forceSliderMoved(forceSlider: UISlider) {
		force = forceSlider.value * 300.0
	}
	
	//	MARK: Initialisation
	required init(coder aDecoder: NSCoder) {
		cube = scene.rootNode.childNodeWithName("Cube", recursively: false)!
		super.init(coder: aDecoder)
	}
	
	//	MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		sceneView.scene = scene
		sceneView.allowsCameraControl = true
		sceneView.showsStatistics = true
		sceneView.delegate = self
		
		scene.physicsWorld.gravity = SCNVector3Make(0.0, -9.8, 0.0)
		cube.physicsBody = SCNPhysicsBody.dynamicBody()
		cube.physicsBody!.mass = 5.0
		cube.physicsBody!.restitution = 0.01
		
		if let slope = scene.rootNode.childNodeWithName("Slope", recursively: false) {
			slope.physicsBody = SCNPhysicsBody.kinematicBody()
			slopeNode.addChildNode(slope)
			scene.rootNode.addChildNode(slopeNode)
			slopeNode.pivot = SCNMatrix4MakeTranslation(-7.0, 0.0, 0.0)
			slopeNode.position = SCNVector3Make(-7.0, 0.0, 0.0)
			
			sliderJoint = SCNPhysicsSliderJoint(
				bodyA: cube.physicsBody,
				axisA: SCNVector3Make(0.0, -1.0, 0.0),
				anchorA: SCNVector3Make(0.0, 0.0, -1.0),
				bodyB: slope.physicsBody,
				axisB: SCNVector3Make(0.0, -1.0, 0.0),
				anchorB: SCNVector3Make(0.0, 0.0, -0.20))
			
			sliderJoint.maximumAngularLimit = 0.0
			sliderJoint.minimumAngularLimit = 0.0
			
			sliderJoint.maximumLinearLimit = 4.0
			sliderJoint.minimumLinearLimit = -5.5
			
			scene.physicsWorld.addBehavior(sliderJoint)
			
			cube.physicsBody!.categoryBitMask = 1
			cube.physicsBody!.collisionBitMask = 1
			slope.physicsBody!.categoryBitMask = 2
			slope.physicsBody!.collisionBitMask = 2
		}
	}
}

//	MARK: SCNSceneRendererDelegate
extension GameViewController: SCNSceneRendererDelegate {
	//	MARK: Rendering
	func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
		if applyForce {
			cube.physicsBody!.applyForce(SCNVector3Make(force, 0.0, 0.0), impulse: false)
		}
	}
}