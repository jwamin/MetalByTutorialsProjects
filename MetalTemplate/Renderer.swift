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
    var vertexBuffer:MTLBuffer!
    var pipelineState:MTLRenderPipelineState!
    
    private var drawTriangles:Bool = true
    
    //animation related instance variables
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
        
        //Tells the GPU about the layout of streamed data
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        //
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        let allocator = MTKMeshBufferAllocator(device: device)
        
        // Get mesh from file, first, create modelIO asset
        let asset = MDLAsset(url: importmeshFile, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
        //cast to modelIO mesh
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        //cast to metal mesh
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)} catch {
            print("error casting to metal mesh")
        }
        
        //Generate pipeline descriptor, there is no need to save access to the library, simply parse the metal shaders and assign the functions to the pipeline Descriptor
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        //Create pipeline descriptor and assign shader functions
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        //Get vertex descriptor from mesh via modelIO
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
        //get pixel format from view
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        //compine all into pipeline state which will be used by draw function
        do{
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error{
            print(error.localizedDescription)
        }
        
        //finally, call super
        super.init()
        
        //set background color for GPU draw
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        //assign metalkitview delegate to self, which starts the draw loop
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
        
        if(drawTriangles){
            renderEncoder.setTriangleFillMode(.lines)
        }
        
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        for submesh in mesh.submeshes{
            
            print(submesh.indexCount,submesh.indexType,submesh.indexBuffer.buffer,submesh.indexBuffer.offset)
            
            renderEncoder.drawIndexedPrimitives(type: ((drawTriangles) ? .triangle : .point), indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
            
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
}
