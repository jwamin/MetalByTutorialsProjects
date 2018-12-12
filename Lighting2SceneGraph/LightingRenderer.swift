//
//  Renderer.swift
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import MetalKit


class Renderer:NSObject{
    
    static var device:MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var colorPixelFormat: MTLPixelFormat!
    static var library:MTLLibrary!
    var mesh:MTKMesh!
    var vertexBuffer:MTLBuffer!
    var pipelineState:MTLRenderPipelineState!
    var depthStencilState:MTLDepthStencilState!
    
    private var drawTriangles:Bool = true
    public var cycle:Bool = false
    
    //animation related instance variables
   //var time:Float = 0
    var constants = Constants()
    
    var magenta:float4 = float4(1, 0, 1, 1);
    
    var uniforms = Uniforms()
    
    let projectionFOV:Float = 70
    var rotationDegs:Float = 45
    var yRotationDegs:Float = 0
    var zScale:Float = 0
    
    let scene:Scene = Scene()

    lazy var sunlight:Light = {
       var light = buildDefaultLight()
        light.position = [1,2,-2]
        return light
    }()
    
    lazy var ambientLight:Light = {
        var light = Light()
        light.color = [0.5,1,0]
        light.intensity = 0.2
        light.type = Ambientlight
        return light
    }()
    
    var fragmentUniforms = FragmentUniforms()
    
    init(metalView:MTKView){
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("no device")
        }
        
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.device = device
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        Renderer.device = device
        Renderer.commandQueue = device.makeCommandQueue()!
        Renderer.library = device.makeDefaultLibrary()

        let model2 = Model(objName: "primative",modelExtn: "usd")
        model2.position = float3(0,1,1)
        let model = Model(objName: "choo-choo",modelExtn: "obj")
        scene.nodes.append(model)
        scene.nodes.append(model2)
        
    
        
        //finally, call super
        super.init()
        
        //set wierd off-yellow background color for GPU draw
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        //assign metalkitview delegate to self, which starts the draw loop
        metalView.delegate = self
        
        let translation = float4x4(translation: [0, 0.0, zScale])
        let rotation = float4x4(rotation: [0,radians(fromDegrees: self.rotationDegs),0])
        
        uniforms.modelMatrix = translation * rotation
        
        uniforms.viewMatrix = float4x4(translation: [0.5,0,0]).inverse
        
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
        
        buildDepthStencilState()
        
        scene.lights.append(sunlight)
        scene.lights.append(ambientLight)
        fragmentUniforms.lightCount = UInt32(scene.lights.count)
    }
}


extension Renderer:MTKViewDelegate{
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        
        let projectionMatrix = float4x4(projectionFov: radians(fromDegrees: projectionFOV), near: 0.1, far: 100, aspect: aspect)
        
        uniforms.projectionMatrix = projectionMatrix
    }
    
    
    
    func draw(in view: MTKView) {
        
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        renderEncoder.setDepthStencilState(depthStencilState)
        
        //don't cycle through time, but get mouse input
        let translation = float4x4(translation: [0, 0.0, zScale])
        let rotation = float4x4(rotation: [radians(fromDegrees: self.yRotationDegs),radians(fromDegrees: self.rotationDegs),0])
            
        //uniforms.modelMatrix = translation * rotation
 
        
        
        uniforms.viewMatrix = float4x4(translation: [0, 0, -3]).inverse * rotation
        
        //set normal matrix here
        uniforms.normalMatrix = float3x3(normalFrom4x4: uniforms.modelMatrix)
        
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.setFragmentBytes(&magenta, length: MemoryLayout<float4>.stride, index: 0)
        renderEncoder.setFragmentBytes(&scene.lights, length: MemoryLayout<Light>.stride * scene.lights.count, index: 2)
        renderEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: 3)
        
        // render all the models in the array
        for model in scene.nodes as! [Model] {
            // model matrix now comes from the Model's superclass: Node
            uniforms.modelMatrix = model.modelMatrix * translation
            uniforms.normalMatrix = float3x3(normalFrom4x4: model.modelMatrix)
            
            renderEncoder.setVertexBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride, index: 1)
            
            renderEncoder.setRenderPipelineState(model.pipelineState)
            renderEncoder.setVertexBuffer(model.vertexBuffer, offset: 0, index: 0)
            for submesh in model.mesh.submeshes {
                renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                    indexCount: submesh.indexCount,
                                                    indexType: submesh.indexType,
                                                    indexBuffer: submesh.indexBuffer.buffer,
                                                    indexBufferOffset: submesh.indexBuffer.offset)
            }
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}


extension Renderer {
    
    func setTriangles(drawTriangles:Bool){
        self.drawTriangles = drawTriangles
    }
    
    func buildDepthStencilState(){
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func buildDefaultLight()->Light{
        var light = Light()
        light.position = [0,0,0]
        light.color = [1,1,1]
        light.specularColor = [0.6,0.6,0.6]
        light.intensity = 1
        light.attenuation = float3(x: 1, y: 0, z: 0)
        light.type = Sunlight
        return light
    }
    
}
