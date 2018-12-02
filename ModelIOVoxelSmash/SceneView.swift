//
//  SceneView.swift
//  ModelIOVoxelSmash
//
//  Created by Joss Manger on 11/30/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import SceneKit
import Cocoa
import ModelIO

class SceneKitRenderer : NSObject{
    
    var view:SCNView!
    var scene:SCNScene!
    
    var voxelsLoaded = false
    var physicsApplied = false
    
    var parentNode:SCNNode!
    
    init(view:SCNView) {
        super.init()
        self.view = view
        scene = SCNScene()
        view.scene = scene
        //view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        let sky = MDLSkyCubeTexture(name: nil,
                                    channelEncoding: MDLTextureChannelEncoding.uInt8,
                                    textureDimensions: [Int32(160), Int32(160)],
                                    turbidity: 1,
                                    sunElevation: 14,
                                    upperAtmosphereScattering: 0.7,
                                    groundAlbedo: 0.5)
        scene.background.contents = sky.imageFromTexture()?.takeUnretainedValue()
        
        
        //establish camera node
        let cameraNode = SCNNode()
        cameraNode.position = SCNVector3(0, 1, 3)
        let camera = SCNCamera()
        cameraNode.camera = camera
        //cameraNode.constraints.a
        
        view.pointOfView = cameraNode;
        view.allowsCameraControl = true
        view.defaultCameraController.interactionMode = .fly
        
        
        view.scene?.rootNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        //view.cameraControlConfiguration = SCN
        
        parentNode = SCNNode()
        parentNode.name = "voxelParentNode"
        
        let floor = SCNFloor()
        let node = SCNNode(geometry: floor)
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.position.y = -0.6
        scene.rootNode.addChildNode(node)
        view.isPlaying = true
        
   
    }
    
    
    func applyForce(){
        //force apply
//        if let forcenode = parentNode.childNode(withName: "forceNode", recursively: false){
//            forcenode.physicsBody?.applyForce(SCNVector3(10,10,10), at:forcenode.position, asImpulse: true)
//        } else {
//
//            let node = SCNNode()
//            let geo = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
//            geo.firstMaterial?.diffuse.contents = NSColor.red.cgColor
//            node.geometry = geo
//            node.name = "forceNode"
//            node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//            parentNode.addChildNode(node)
//            node.physicsBody?.applyForce(SCNVector3(10,10,10), at: node.position, asImpulse: true)
//
//        }
        
        
        if let parent = parentNode{
            for childNode in parent.childNodes{
                if childNode.physicsBody == nil{
                    childNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                }
                childNode.physicsBody?.applyForce(SCNVector3(2,2,0), at: parentNode.position, asImpulse: true)
            }
            
        }
        
    }
    
    func initialiseMesh(){
        
        if(!voxelsLoaded){
        print("loading mesh")
        let mesh = MDLMesh(sphereWithExtent: [0.5,0.5,0.5], segments: [100,100], inwardNormals: false, geometryType: .triangles, allocator: nil)
        
        let asset = MDLAsset()
        asset.add(mesh)
        

        
        let divisions = 15
            
        let voxelArray = MDLVoxelArray(asset:asset, divisions: 10, interiorShells: 1, exteriorShells: 1, patchRadius: 0)
        
        let voxelIndices = voxelArray.voxelIndices()
        if let data = voxelIndices {data.withUnsafeBytes( { (voxels:UnsafePointer<MDLVoxelIndex>) -> Void in
            
            let count = data.count / MemoryLayout<MDLVoxelIndex>.size
            
            for voxelIndex in 0 ..< count {
                print(voxels[voxelIndex])
                let box = SCNSphere(radius: 0.5 / CGFloat(divisions))
                let node = SCNNode(geometry: box)
                
                switch(voxels[voxelIndex].w){
                case 0:
                    box.firstMaterial?.diffuse.contents = NSColor.red.cgColor
                case -1:
                    box.firstMaterial?.diffuse.contents = NSColor.green.cgColor
                default:
                    box.firstMaterial?.diffuse.contents = NSColor.blue.cgColor
                    break;
                }
                
                let voxPos = voxelArray.spatialLocation(ofIndex: voxels[voxelIndex])
                node.position = SCNVector3(voxPos.x,voxPos.y,voxPos.z)
                parentNode.addChildNode(node)
                
            }
            parentNode.position.y = 1
            scene.rootNode.addChildNode(parentNode)
            
            
            
        })
        }
        voxelsLoaded = true
            //view.allowsCameraControl = true
        } else if (!physicsApplied){
            physicsApplied = true
            print("applying physics")
            guard let parent = scene.rootNode.childNode(withName: "voxelParentNode", recursively: false) else {
                fatalError()
            }
            for node in parent.childNodes{
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
               
            }
            
            
            
            
        } else if (physicsApplied && voxelsLoaded){
            let parent = scene.rootNode.childNodes[1]
            parent.childNodes.map{
                $0.removeFromParentNode()
            }
            physicsApplied = !physicsApplied
            voxelsLoaded = !voxelsLoaded
        }
        
        
        
    }
    
    
}
