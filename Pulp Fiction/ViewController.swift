//
//  ViewController.swift
//  Pulp Fiction
//
//  Created by Saurabh Jain on 1/9/18.
//  Copyright © 2018 Saurabh Jain. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/gatorEdited.dae")!
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        loadAnimations()
        
        
    }
    
    func loadAnimations () {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/gatorEdited.dae")!
        
        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // Set up some properties
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.005, 0.005, 0.005)
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Load all the DAE animations
        loadAnimation(withKey: "taunt", sceneName: "gatorTauntEdited", animationIdentifier: "gatorTauntEdited-1")
        //loadAnimation(withKey: "die", sceneName: "gatorDyingEdited", animationIdentifier: "gatorDyingEdited-1")
    }
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        
        if let sceneURL = URL(string: "https://s3-us-west-1.amazonaws.com/whare-asset-bundles/sjain/" + sceneName + ".dae") {
//        if let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae") {
            do {
                
                let fileContent = try String(contentsOf: sceneURL)
                let data = fileContent.data(using: String.Encoding.utf8)
                print(data)
                
                let sceneSource = SCNSceneSource(data: data!)
                let identifiers = sceneSource?.identifiersOfEntries(withClass: CAAnimation.self)
                if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
                    // The animation will only play once
                    animationObject.repeatCount = 10
                    // To create smooth transitions between animations
                    animationObject.fadeInDuration = CGFloat(1)
                    animationObject.fadeOutDuration = CGFloat(0.5)
                    
                    // Store the animation for later use
                    animations[withKey] = animationObject
                }
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }
        
        
        //let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
//        if hitResults.first != nil {
            if(idle) {
                playAnimation(key: "taunt")
                stopAnimation(key: "die")
            } else {
                playAnimation(key: "die")
                stopAnimation(key: "taunt")
            }
            idle = !idle
            return
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
