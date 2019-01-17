//
//  ViewController.swift
//  ARDicee
//
//  Created by Clovis Magenta da Cunha on 15/01/19.
//  Copyright © 2019 CMC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
         
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            
            configuration.planeDetection = .horizontal
            // Run the view's session
            sceneView.session.run(configuration)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: Dice Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            let touchResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if !touchResults.isEmpty {
                
                if let hitResult = touchResults.first {
                    
                    addDice(atLocation: hitResult)
                    
                }
                
            }
            
        }
    }
    
    func addDice(atLocation location: ARHitTestResult) {
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        
            if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                x:location.worldTransform.columns.3.x,
                y:location.worldTransform.columns.3.y + diceNode.boundingSphere.radius, // it is necessary because otherwise only half of dice would be above plane
                z:location.worldTransform.columns.3.z
            )
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
            let randomZ = Float(arc4random_uniform(4)+1) * (Float.pi/2)
            
            diceNode.runAction(
                SCNAction.rotateBy(
                    x: CGFloat(randomX * 5),
                    y: 0,
                    z: CGFloat(randomZ * 5),
                    duration: 0.5)
            )
        }
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    
        rollAll()
        
    }
    
    func roll( dice: SCNNode ) {
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4)+1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll( dice: dice )
            }
        }
        
    }
    
    //MARK: BarButton Methods
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    @IBAction func rollDiceAction(_ sender: UIBarButtonItem) {
        
        rollAll()
        
    }

    
    //MARK: ARSCNViewDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
        
    }

    //MARK: Plane Rendering methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(x:planeAnchor.center.x, y:planeAnchor.center.y, z: planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    }

}




/* History of planetary testing
 let myCube = SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0.01)
 let myMoon = SCNSphere(radius: 0.6)
 let myMars = SCNSphere(radius: 0.5)
 let myEarth = SCNSphere(radius: 0.9)
 
 let material = SCNMaterial()
 let moonMaterial = SCNMaterial()
 let marsMaterial = SCNMaterial()
 let earthMaterial = SCNMaterial()
 
 material.diffuse.contents = UIColor.red
 myCube.materials = [material]
 
 moonMaterial.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
 myMoon.materials = [moonMaterial]
 
 marsMaterial.diffuse.contents = UIImage(named: "art.scnassets/8k_mars.jpg")
 myMars.materials = [marsMaterial]
 
 earthMaterial.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpg")
 myEarth.materials = [earthMaterial]
 
 let cubeNode = SCNNode()
 cubeNode.position = SCNVector3(3, 0.1, -0.5)
 cubeNode.geometry = myCube
 sceneView.scene.rootNode.addChildNode(cubeNode)
 
 let moonNode = SCNNode()
 moonNode.position = SCNVector3(-5, 1.5, -0.3)
 moonNode.geometry = myMoon
 sceneView.scene.rootNode.addChildNode(moonNode)
 
 let marsNode = SCNNode()
 marsNode.position = SCNVector3(-5.5, -0.4, -0.3)
 marsNode.geometry = myMars
 sceneView.scene.rootNode.addChildNode(marsNode)
 
 let earthNode = SCNNode()
 earthNode.position = SCNVector3(-3, 6, -0.3)
 earthNode.geometry = myEarth
 sceneView.scene.rootNode.addChildNode(earthNode)
 
 sceneView.autoenablesDefaultLighting = true
 
 */
