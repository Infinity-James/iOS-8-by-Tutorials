//	James is strong

import Foundation
import SceneKit

class Molecules {
	
	class func ethanolMolecule() -> SCNNode {
		let ethanolMolecule = SCNNode()
		
		let scene = SCNScene(named: "EthanolScene")!
		for child in scene.rootNode.childNodes as! [SCNNode] {
			ethanolMolecule.addChildNode(child)
		}
		
		return ethanolMolecule
	}
	
	class func methaneMolecule() -> SCNNode {
		let methaneMolecule = SCNNode()
		
		let carbonNodeA = nodeWithAtom(Atoms.carbonAtom(), molecule: methaneMolecule, position: SCNVector3Make(0.0, 0.0, 0.0))
		
		let hydrogenNodeA = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(-4.0, 0.0, 0.0))
		let hydrogenNodeB = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(4.0, 0.0, 0.0))
		let hydrogenNodeC = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0.0, -4.0, 0.0))
		let hydrogenNodeD = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0.0, 4.0, 0.0))
		
		//	add lines between atoms
		methaneMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: hydrogenNodeA))
		methaneMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: hydrogenNodeB))
		methaneMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: hydrogenNodeC))
		methaneMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: hydrogenNodeD))
		
		return methaneMolecule
	}
	
	class func ptfeMolecule() -> SCNNode {
		let ptfeMolecule = SCNNode()
		
		var carbonNodePrevious: SCNNode?
		
		for index in -1...1 {
			let index = Float(index)
			
			let carbonNodeA = nodeWithAtom(Atoms.carbonAtom(), molecule: ptfeMolecule, position: SCNVector3Make(-2.0 + (index * 8.0), 2.0, 0.0))
			let carbonNodeB = nodeWithAtom(Atoms.carbonAtom(), molecule: ptfeMolecule, position: SCNVector3Make(2.0 + (index * 8.0), -2.0, 0.0))
			
			let fluorineNodeA = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(-2.0 + (index * 8.0), -4.0, 2.0))
			let fluorineNodeB = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(-2.0 + (index * 8.0), -4.0, -2.0))
			let fluorineNodeC = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(2.0 + (index * 8.0), 4.0, 2.0))
			let fluorineNodeD = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(2.0 + (index * 8.0), 4.0, -2.0))
			
			ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: carbonNodeB))
			ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: fluorineNodeA))
			ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: fluorineNodeB))
			ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNodeB, andNodeB: fluorineNodeC))
			ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNodeB, andNodeB: fluorineNodeD))
			
			if let lastCarbonNode = carbonNodePrevious {
				ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNodeA, andNodeB: lastCarbonNode))
			}
			
			carbonNodePrevious = carbonNodeB.copy() as? SCNNode
		}
		
		return ptfeMolecule
	}
	
	class func nodeWithAtom(atom: SCNGeometry, molecule: SCNNode, position: SCNVector3) -> SCNNode {
		let node = SCNNode(geometry: atom)
		node.position = position
		molecule.addChildNode(node)
		return node
	}
	
	class func lineBetweenNodeA(nodeA: SCNNode, andNodeB nodeB: SCNNode) -> SCNNode {
		//	position of the vertices of the line
		let positions: [Float32] = [nodeA.position.x, nodeA.position.y, nodeA.position.z, nodeB.position.x, nodeB.position.y, nodeB.position.z]
		let positionData = NSData(bytes: positions, length: sizeof(Float32) * positions.count)
		
		//	the indices for rendering (only two points on a line - the ends)
		let indices: [Int32] = [0, 1]
		let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
		
		/**
			data:				geometry data
			semantic:			type of geometry source
			vectorCount:		number of source vectors (two: start and end)
			floatComponents:	all vertices are float components
			componentsPerVector:the number of scalar components (three: x, y, z)
			bytesPerComponent:	number of bytes representing vector component
			dataOffset:			offset from beginning of data
			dataStride:			number of bytes from one vector to the next in the data (three Float32s)
		 */
		let source = SCNGeometrySource(data: positionData, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32) * 3)
		//	make a line element
		let element = SCNGeometryElement(data: indexData, primitiveType: .Line, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
		
		//	create the line
		let line = SCNGeometry(sources: [source], elements: [element])
		return SCNNode(geometry: line)
	}
}