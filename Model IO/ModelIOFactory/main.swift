//
//  main.swift
//  ModelIOFactory
//
//  Created by Joss Manger on 11/30/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import Foundation
import MetalKit
import SceneKit

//Creates MDL Mesh and exports as

print("Creating Assets!")
    
    let mdlmesh = MDLMesh.init(capsuleWithExtent: [0.5,0.5,0.5], cylinderSegments: [50,50], hemisphereSegments: 50, inwardNormals: false, geometryType: .triangles, allocator: nil)
    
let asset = MDLAsset()
asset.add(mdlmesh)



//save mesh in various file formats
let fileextension = ["usd","obj","dae"];
let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
for extn in fileextension{
    guard MDLAsset.canExportFileExtension(extn) else {
       continue
    }
    
    do{
        let url = URL(fileURLWithPath: path).appendingPathComponent("Metal/models/primative."+extn)
        try asset.export(to: url)
    }
}

print("done!")


