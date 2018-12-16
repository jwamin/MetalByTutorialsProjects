//
//  Scene.swift
//  Lighting2SceneGraph
//
//  Created by Joss Manger on 12/11/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import MetalKit

class Scene : NSObject{
    
    var nodes:[Node] = [Node]()
    var lights:[Light] = [Light]()
    var camera:Node = Node()
}



class Node {
    var name: String = "untitled"
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: float3 = [1, 1, 1]
    
    var modelMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * rotateMatrix * scaleMatrix
    }
    
}
