//
//  GameViewController.swift
//  Game MDA 2020
//
//  Created by Kartinin Studio on 26.11.2020.
//

//import UIKit
//import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    // MARK: - Outlets
    let button = UIButton()
    let label = UILabel()
    
    //MARK: - Stored Properties
    var ship: SCNNode!
    var scene: SCNScene!
    var scnView: SCNView!
    var shipLife = Int()
    var attack  = Int()
    var duration: TimeInterval = 5
    var score = 0 {
        didSet {
            print(score)
            label.text = "Score: \(score)"
        }
    }

    //MARK: - Methods
    func addLabel() {
        label.font = UIFont.systemFont(ofSize: 30)
        label.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: 100)
        label.numberOfLines = 2
        label.textAlignment = .center
        scnView.addSubview(label)
        score = 0
    }
    /// Sdds a button to the scene view
    func addButton() {
        let midX = scnView.frame.midX
        let midY = scnView.frame.midY
        let width: CGFloat = 200
        let height: CGFloat = 50
        button.frame = CGRect(x: midX - width/2, y: midY - height/2, width: width, height: height)
        
        //configure button
        button.backgroundColor = .red
        button.isHidden = true
        button.layer.cornerRadius = 15
        button.setTitle("Restart", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        button.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        
        //Add button to the scene
        scnView.addSubview(button)
    }
    
    func addShip() {
        scene.rootNode.addChildNode(ship)
    }
    
    /// clone new ship create
    /// - Returns: SCNNode with new ship
    func getShip() -> SCNNode {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        ship = scene.rootNode.childNode(withName: "ship", recursively: true)!.clone()
        
        // Move ship far away
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -105
        ship.position = SCNVector3(x, y, z)
        ship.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
        attack = 0
        shipLife = 3
        
        //Add animation to move the ship to origin
        ship.runAction(.move(to: SCNVector3(), duration: duration), completionHandler: {
            DispatchQueue.main.async {
                self.button.isHidden = false
                self.label.text = "Game Over\nScore: \(self.score)"
            }
        })
        
        
        return ship
    }
    
    // Finds and removes the ship from the scene
    func removeShip(){
        scene.rootNode.childNode(withName: "ship", recursively: true)?.removeFromParentNode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        //remove the first Ship
        removeShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
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
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        scnView = self.view as? SCNView
        
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
        
        // Add ship to the scene
        let ship = getShip()
        addShip()
        
        addButton()
        addLabel()
    }
    
    //MARK: - Actions
    @objc func restartGame() {
        button.isHidden =  true
        removeShip()
        ship = getShip()
        addShip()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
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
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.attack += 1
                if self.attack == self.shipLife {
                    self.ship.removeFromParentNode()
                    self.duration *= 0.9
                    self.score += 1
                    self.ship = self.getShip()
                    self.addShip()
                }
                
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
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
