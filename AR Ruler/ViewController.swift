//
//  ViewController.swift
//  AR Ruler
//
//  Created by Yesbolat Syilybay on 21.09.2020.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
	var dotNodes = [SCNNode]()
	var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
		sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touchLocation = touches.first?.location(in: sceneView) {
			let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
			if let hitResult = hitTestResults.first {
				addDot(at: hitResult)
			}
		}
	}
	
	func addDot(at hitResult: ARHitTestResult) {
		if dotNodes.count == 2 {
			deleteAllNodes()
		}
		
		let dotGeometry = SCNSphere(radius: 0.005)
		let dotMaterial = SCNMaterial()
		dotMaterial.diffuse.contents = UIColor.red
		
		dotGeometry.materials = [dotMaterial]
		
		let dotNode = SCNNode(geometry: dotGeometry)
		dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
									  hitResult.worldTransform.columns.3.y,
									  hitResult.worldTransform.columns.3.z)
		sceneView.scene.rootNode.addChildNode(dotNode)
		dotNodes.append(dotNode)
		
		if dotNodes.count == 2 {
			calculate()
		}
	}
	
	func calculate() {
		let startPoint = dotNodes[0].position
		let endPoint = dotNodes[1].position
		
		let a = startPoint.x - endPoint.x
		let b = startPoint.y - endPoint.y
		let c = startPoint.z - endPoint.z
		
		let distance = abs(sqrt(a * a + b * b + c * c))
		showResult(with: String(format: "%.3f", distance), atPosition: endPoint)
	}
	
	func showResult(with text: String, atPosition position: SCNVector3) {
		let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
		textGeometry.firstMaterial?.diffuse.contents = UIColor.red
		
		textNode = SCNNode(geometry: textGeometry)
		textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
		textNode.scale = SCNVector3(0.01, 0.01, 0.01)
		
		sceneView.scene.rootNode.addChildNode(textNode)
	}
	
	func deleteAllNodes() {
		for node in dotNodes {
			node.removeFromParentNode()
		}
		dotNodes = [SCNNode]()
		textNode.removeFromParentNode()
	}
}
