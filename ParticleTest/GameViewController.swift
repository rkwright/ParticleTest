//
//  GameViewController.swift
//  ParticleTest
//
//  Created by rkwright on 1/6/21.
//
//  This is partially based on an article by Ray Wenderlich:
//   https://www.raywenderlich.com/1260-scene-kit-tutorial-with-swift-part-2-nodes
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    
    
    /**
     *  Use the viewDidLoad() overrride to construct our scene.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = createScene()
        
        createCamera(scene)
        
        createLights(scene)

        let ship = fetchShip(scene)
       
        let geometry:SCNGeometry = SCNSphere(radius: 1.0)
        
        geometry.materials.first?.diffuse.contents = UIColor.red

        let trailEmitter = createTrail(color: UIColor.red, geometry: geometry)
       
        ship.addParticleSystem(trailEmitter)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    /**
     * Create the scene by loading it from the app's resources
     */
    func createScene () -> SCNScene {
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        return scene
    }
    
    /**
     * Load the ship from the app's resources then set it rotating
     */
    func fetchShip ( _ scene: SCNScene ) ->SCNNode {
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively:true)!
        
        // animate the 3d object
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))

        return ship
    }
    
    /**
     * Just create a single camera and point it at the scene
     */
    func createCamera ( _ scene: SCNScene ) {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
    }

    /**
     *  Create the lights for the scene.
     *  Should return a tuple.  TODO
     */
    func createLights ( _ scene: SCNScene ) {
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
    }

    /**
     * Create the trail system in memory by loading the file (actually in app's resources)
     */
    func createTrail ( color: UIColor, geometry: SCNGeometry ) -> SCNParticleSystem {
        
      // Fetch the particle system from the file
      let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        
      // set the color and geometry
      trail.particleColor = color
      trail.emitterShape = geometry
      
      return trail
    }
    
    /**
     * Tap handler
     */
    @objc
    func handleTap ( _ gestureRecognize: UIGestureRecognizer ) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    /**
     * Handle the device orientation changes
     */
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
