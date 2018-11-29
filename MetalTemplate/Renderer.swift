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
    
    var mesh:MTKMesh!
    var mdlMesh:MDLMesh!
    var vertexBuffer:MTLBuffer!
    var pipelineState:MTLRenderPipelineState!
    var time:Float = 0
    var constants = Constants()
    init(metalView:MTKView){
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("no device")
        }
        
        metalView.device = device
        Renderer.commandQueue = device.makeCommandQueue()!
        
        guard let importmeshFile = Bundle.main.url(forResource: "choo-choo", withExtension: "obj") else {
            fatalError()
        }
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        let allocator = MTKMeshBufferAllocator(device: device)
//        let mdlMesh = Primitive.makeCube(device: device, size: 1)
//        do{
//            mesh = try MTKMesh(mesh: mdlMesh, device: device)
//        } catch let error {
//            print(error.localizedDescription)
//        }
    
//
        
        let asset = MDLAsset(url: importmeshFile, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
        
        //vertexBuffer = mesh.vertexBuffers[0].buffer
        
        mdlMesh = asset.object(at: 0) as! MDLMesh
        
        mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
       print(mesh.submeshes)
        
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
   
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        do{
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error{
            print(error.localizedDescription)
        }
        
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
        print("initialised")
    }
}


extension Renderer:MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    func draw(in view: MTKView) {
      
        guard let descriptor = view.currentRenderPassDescriptor,
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        time += deltaTime
        let animateBy = abs(sin(time)/2 + 0.5)
        constants.animateBy = animateBy
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setTriangleFillMode(.lines)
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        for submesh in mesh.submeshes{
            
            print(submesh.indexCount,submesh.indexType,submesh.indexBuffer.buffer,submesh.indexBuffer.offset)
            
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
            
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
