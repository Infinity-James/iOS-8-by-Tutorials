///	James is awesome

import UIKit
import SceneKit

class ViewController: UIViewController {
	
	//	MARK: Properties
	@IBOutlet weak var geometryLabel: UILabel!
	@IBOutlet weak var sceneView: SCNView!
	
	var geometryNode = SCNNode()
	var currentAngle: Float = 0.0
	
	// MARK: Actions
	@IBAction func segmentValueChanged(segmentedControl: UISegmentedControl) {
		geometryNode.removeFromParentNode()
		currentAngle = 0.0
		
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			geometryLabel.text = "Atoms\n"
			geometryNode = Atoms.allAtoms()
		case 1:
			geometryLabel.text = "Methane\n(Natural Gas)"
			geometryNode = Molecules.methaneMolecule()
		case 2:
			geometryLabel.text = "Ethanol\n(Alcohol)"
			geometryNode = Molecules.ethanolMolecule()
		case 3:
			geometryLabel.text = "Polyetrafluorethylene\n(Teflon)"
			geometryNode = Molecules.ptfeMolecule()
		default:
			break
		}
		
		sceneView.scene!.rootNode.addChildNode(geometryNode)
	}
	
	//	MARK: Gestures
	func panGesture(panGestureRecognizer: UIPanGestureRecognizer) {
		let translation = panGestureRecognizer.translationInView(panGestureRecognizer.view!)
		var newAngle = Float(translation.x)
		newAngle *= Float(M_PI) / 180.0
		newAngle += currentAngle
		
		geometryNode.transform = SCNMatrix4MakeRotation(newAngle, 0.0, 1.0, 0.0)
		
		if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
			currentAngle = newAngle
		}
	}
	
	// MARK: View Lifecycle
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		sceneSetup()
		
		geometryLabel.text = "Atoms\n"
		geometryNode = Atoms.allAtoms()
		sceneView.scene!.rootNode.addChildNode(geometryNode)
	}
	
	//	MARK: Scene
	private func sceneSetup() {
		let scene = SCNScene()
		
		//	ambient light
		let ambientLight = SCNLight()
		ambientLight.type = SCNLightTypeAmbient
		ambientLight.color = UIColor(white: 0.67, alpha: 1.0)
		let ambientLightNode  = SCNNode()
		ambientLightNode.light = ambientLight
		scene.rootNode.addChildNode(ambientLightNode)
		
		//	omni light
		let omniLight = SCNLight()
		omniLight.type = SCNLightTypeOmni
		omniLight.color = UIColor(white: 0.75, alpha: 1.0)
		let omniLightNode = SCNNode()
		omniLightNode.light = omniLight
		omniLightNode.position = SCNVector3Make(0.0, 50.0, 50.0)
		scene.rootNode.addChildNode(omniLightNode)
		
		//	camera
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3Make(0.0, 0.0, 25.0)
		scene.rootNode.addChildNode(cameraNode)
		
		sceneView.scene = scene
		
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
		sceneView.addGestureRecognizer(panGestureRecognizer)
	}
	
	// MARK: Style
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	// MARK: Transition
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		sceneView.stop(nil)
		sceneView.play(nil)
	}
}
