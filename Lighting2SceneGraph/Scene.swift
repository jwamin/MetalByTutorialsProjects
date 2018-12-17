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
    var camera:Camera
    
    init(camera:Camera) {
        self.camera = camera
        super.init()
    }
    
}



class Node {
    var name: String = "untitled"
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]{
        didSet{
            updateMatrices()
        }
    }
    var scale: float3 = [1, 1, 1]
    var nodes:[Node] = []
    
    var modelMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * rotateMatrix * scaleMatrix
    }
    
    var updatedModelMatrix:float4x4?
    
    func updateMatrices(){
        for node in nodes{
            let positionf4 = float4x4(translation: [node.position.x,node.position.y,node.position.z])
            let multiplied:float4x4 = modelMatrix * positionf4
            node.updatedModelMatrix = multiplied
        }
    }
    
    func addChild(node:Node){
        
        nodes.append(node)
        updateMatrices()
        print(position,node.position)
    }
    
}

class Camera : Node{
    
    var projectionMatrix:float4x4
    
    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = float4( x,  0,  0,  0)
        let Y = float4( 0,  y,  0,  0)
        let Z = lhs ? float4( 0,  0,  z, 1) : float4( 0,  0,  z, -1)
        let W = lhs ? float4( 0,  0,  z * -near,  0) : float4( 0,  0,  z * near,  0)
        projectionMatrix = float4x4(X, Y, Z, W)
        super.init()
        
    }
    
}
