//
//  Primitive.swift
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import MetalKit

class Primitive {
    class func makeCube(device:MTLDevice,size:Float) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(boxWithExtent: [size,size,size], segments: [1,1,1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        return mesh
    }
}
