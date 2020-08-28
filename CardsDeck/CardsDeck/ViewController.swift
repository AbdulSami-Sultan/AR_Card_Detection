//
//  ViewController.swift
//  CardsDeck
//
//  Created by Macbook on 28/02/2020.
//  Copyright © 2020 Sami. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var heartNode : SCNNode?
    var diamondNode : SCNNode?
    
    var imageNode = [SCNNode]()
    var isJumping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        let heartScene = SCNScene(named: "art.scnassets/heart.scn")
        let diamondScene = SCNScene(named: "art.scnassets/diamond.scn")
        
        heartNode = heartScene?.rootNode
            diamondNode = diamondScene?.rootNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //give the image tracker to track the given image
        
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Playing Cards", bundle: Bundle.main){
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
            
        }
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        //placing 3d plane at the detected image
        if let imageAnchor = anchor as? ARImageAnchor{
            let size = imageAnchor.referenceImage.physicalSize
            let plane  = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
           // differentiate between nodes design
            
            var shapeNode: SCNNode?
            
            switch imageAnchor.referenceImage.name {
            case CardTypes.king.rawValue:
                shapeNode = heartNode
                case CardTypes.queen.rawValue:
                shapeNode = diamondNode
            default:
                break
            }
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
            
            // if nil is given
            guard let shape = shapeNode else {
                return nil
            }
            node.addChildNode(shape)
            imageNode.append(node)
            return node
            
        }
        return nil
        
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNode.count == 2 {
            let position1 = SCNVector3ToGLKVector3(imageNode[0].position)
        let position2 = SCNVector3ToGLKVector3(imageNode[1].position)
            let distance = GLKVector3Distance(position1, position2)
            print(distance)
            if distance < 0.10
            {
                print("close")
                
               spinJump(node: imageNode[0])
            spinJump(node: imageNode[1])
                isJumping = true
            }else{
                isJumping = false
            }
            
        }
        
    }
    func spinJump(node: SCNNode){
        if isJumping { return }
        let shapeNode = node.childNodes[1]
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        
        let down = up.reversed()
        let upDown = SCNAction.sequence([up,down])
        
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(upDown)
        
    }
    
    enum CardTypes: String {
        case king = "king"
        case queen = "queen"
    }

}



