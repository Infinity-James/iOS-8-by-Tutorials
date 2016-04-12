//	James is the best

import Foundation
import SceneKit

class Atoms {
	class func carbonAtom() -> SCNGeometry {
		let carbonAtom = SCNSphere(radius: 1.70)
		carbonAtom.firstMaterial!.diffuse.contents = UIColor.darkGrayColor()
		carbonAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
		return carbonAtom
	}
	
	class func fluorineAtom() -> SCNGeometry {
		let fluorineAtom = SCNSphere(radius: 1.47)
		fluorineAtom.firstMaterial!.diffuse.contents = UIColor.yellowColor()
		fluorineAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
		return fluorineAtom
	}
	
	class func hydrogenAtom() -> SCNGeometry {
		let hydrogenAtom = SCNSphere(radius: 1.20)
		hydrogenAtom.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
		hydrogenAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
		return hydrogenAtom
	}
	
	class func oxygenAtom() -> SCNGeometry {
		let oxygenAtom = SCNSphere(radius: 1.52)
		oxygenAtom.firstMaterial!.diffuse.contents = UIColor.redColor()
		oxygenAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
		return oxygenAtom
	}
	
	class func allAtoms() -> SCNNode {
		let atomsNode = SCNNode()
		
		let carbonNode = SCNNode(geometry: carbonAtom())
		carbonNode.position = SCNVector3Make(-6.0, 0.0, 0.0)
		atomsNode.addChildNode(carbonNode)
		
		let fluorineNode = SCNNode(geometry: fluorineAtom())
		fluorineNode.position = SCNVector3Make(6.0, 0.0, 0.0)
		atomsNode.addChildNode(fluorineNode)
		
		let hydrogenNode = SCNNode(geometry: hydrogenAtom())
		hydrogenNode.position = SCNVector3Make(-2.0, 0.0, 0.0)
		atomsNode.addChildNode(hydrogenNode)
		
		let oxygenNode = SCNNode(geometry: oxygenAtom())
		oxygenNode.position = SCNVector3Make(2.0, 0.0, 0.0)
		atomsNode.addChildNode(oxygenNode)
		
		return atomsNode
	}
}