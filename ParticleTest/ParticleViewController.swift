//
//  ParticleViewController.swift
//  ParticleTest
//
//  Created by rkwright on 1/6/21.
//
//  This is partially based on an article by Ray Wenderlich:
//  https://www.raywenderlich.com/901-scenekit-tutorial-with-swift-part-5-particle-systems
//

import UIKit
import SceneKit

class ParticleViewController: UIViewController {
  
    /**
     *  Use the viewDidLoad() overrride to construct our scene.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = createScene()
        
        createCamera(scene)
        
        createLights(scene)

        let ship = fetchShip(scene)
       
        transformShip(ship, scene: scene)

        let trailSCNP = createTrailSCNP(color: UIColor.red )
        ship.addParticleSystem(trailSCNP)
        
        let trailCode = createTrailCode(color: UIColor.green )
        ship.addParticleSystem(trailCode)

        configUI(scene)
    }
    
    /**
     * Create the scene by loading it from the app's resources
     */
    func createScene () -> SCNScene {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        return scene
    }
    
    /**
     * Load the ship from the app's resources then set it rotating
     */
    func fetchShip ( _ scene: SCNScene ) ->SCNNode {
        
        let ship = scene.rootNode.childNode(withName: "ship", recursively:true)!
        
        return ship
    }
    
    /**
     * Set up the animation for the ship.  Doesn't do much yet.
     */
    func transformShip(_ ship: SCNNode, scene : SCNScene ) {
        
        let origin = SCNNode()
        
        ship.scale = SCNVector3(x: 0.25, y: 0.25, z: 0.25)
        ship.pivot = SCNMatrix4MakeTranslation(15.0, 0.0, 0.5)
        
        origin.addChildNode(ship)
        scene.rootNode.addChildNode(origin)
        
        origin.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x:0, y:3.14, z:0.0, duration:5)))
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
    func createTrailSCNP ( color: UIColor ) -> SCNParticleSystem {

        // Fetch the particle system from the file
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        
        // set the color and geometry
        trail.particleColor = color
      
      return trail
    }
    
    /*
     * Create a particle system only with code.
     */
    func createTrailCode( color: UIColor ) -> SCNParticleSystem {

        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 5
        particleSystem.birthDirection = .constant
        particleSystem.birthLocation = .vertex
        particleSystem.particleLifeSpan = 5
        particleSystem.warmupDuration = 0
        particleSystem.emissionDuration = 1.0
        particleSystem.emittingDirection = SCNVector3(0,0,0)
        particleSystem.emitterShape = .some(SCNSphere(radius: 0.2))
        particleSystem.loops = true
        particleSystem.particleColor = color
        particleSystem.particleSize = 0.2
        particleSystem.speedFactor = 1
        particleSystem.spreadingAngle = 30
        particleSystem.particleImage = "star"
        particleSystem.isAffectedByGravity = false
        particleSystem.acceleration = SCNVector3(0.0,-1.0,0.0)
        particleSystem.particleBounce = 0.7
        particleSystem.particleFriction = 1
        particleSystem.particleMass = 1
        particleSystem.particleIntensity = 1
        particleSystem.blendMode = .alpha

        return particleSystem
    }

    /**
     * Set up the various user-facing aspects
     */
    func configUI ( _ scene: SCNScene) {
        
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
