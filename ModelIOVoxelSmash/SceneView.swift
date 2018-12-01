//
//  SceneView.swift
//  ModelIOVoxelSmash
//
//  Created by Joss Manger on 11/30/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import SceneKit
import ModelIO

class SceneKitRenderer : NSObject{
    
    var view:SCNView!
    var scene:SCNScene!
    
    var voxelsLoaded = false
    
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
        view.isPlaying = true
    }
    
    
    
    
    func initialiseMesh(){
        
        if(!voxelsLoaded){
        print("loading mesh")
        let mesh = MDLMesh(sphereWithExtent: [0.5,0.5,0.5], segments: [100,100], inwardNormals: false, geometryType: .triangles, allocator: nil)
        
        let asset = MDLAsset()
        asset.add(mesh)
        
        let parentNode = SCNNode()
        
        let voxelArray = MDLVoxelArray(asset: asset, divisions: 25, patchRadius: 0)
        
        let voxelIndices = voxelArray.voxelIndices()
        if let data = voxelIndices {data.withUnsafeBytes( { (voxels:UnsafePointer<MDLVoxelIndex>) -> Void in
            
            let count = data.count / MemoryLayout<MDLVoxelIndex>.size
            
            for voxelIndex in 0 ..< count {
                print(voxels[voxelIndex])
                let box = SCNSphere(radius: 0.02)
                let node = SCNNode(geometry: box)
                let voxPos = voxelArray.spatialLocation(ofIndex: voxels[voxelIndex])
                node.position = SCNVector3(voxPos.x,voxPos.y,voxPos.z)
                parentNode.addChildNode(node)
                
            }
            
            scene.rootNode.addChildNode(parentNode)
            
        })
        }
        voxelsLoaded = true
            view.allowsCameraControl = true
        }
    }
    
    
}
