//
//  main.swift
//  ModelIOVoxels
//
//  Created by Joss Manger on 11/30/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import Foundation
import ModelIO
import SceneKit

let mdlmesh = MDLMesh(boxWithExtent: [0.5,0.5,0.5], segments: [5,5,5], inwardNormals: true, geometryType: .triangles, allocator: nil)

let asset = MDLAsset()
asset.add(mdlmesh)

//MDL Voxels?
let scene = SCNScene()
scene.rootNode.addChildNode(SCNNode())

let grid = MDLVoxelArray(asset: asset, divisions: 25, interiorShells: 200, exteriorShells: 0, patchRadius: 0)
grid.shellFieldInteriorThickness = 1.0
if let data = grid.voxelIndices(){
    
    data.withUnsafeBytes {(voxels: UnsafePointer<MDLVoxelIndex>) in
        let count = data.count / MemoryLayout<MDLVoxelIndex>.size
        for voxelindex in 0 ..< count{
            let box = SCNSphere(radius: 0.01)
            let node = SCNNode(geometry: box)
            print(voxels[voxelindex])
            
            let position = grid.spatialLocation(ofIndex: voxels[voxelindex])
            node.position = SCNVector3(position.x, position.y, position.z)
            scene.rootNode.childNodes[0].addChildNode(node)
//            if(voxelindex>(count/3)){
//                break;
//            }
        }
    }
    
}

let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

let scnurl = URL(fileURLWithPath: path).appendingPathComponent("Scenekit/voxels.scn")

print(scnurl)

let success = scene.write(to: scnurl, options: nil, delegate: nil, progressHandler: {
    (totalProgress, error, stop) in
    print("Progress \(totalProgress) Error: \(String(describing: error))")
})
print("success: \(success)")
