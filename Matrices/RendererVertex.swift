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
    
    private var drawTriangles:Bool = false
    
    //animation related instance variables
    var time:Float = 0
    var constants = Constants()
    
    var magenta:float4 = float4(1, 0, 1, 1);
    var yellow:float4 = float4(1, 1, 0, 1);
    var cyan:float4 = float4(0, 1, 1, 1);
    
    var vertices = [float3(-0.3, 0.4, 0.5)]
    
    var originalBuffer:MTLBuffer!
    var transformedBuffer:MTLBuffer!
    var transformedBuffer2:MTLBuffer!
    
    init(metalView:MTKView){
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("no device")
        }
        
        Renderer.device = device
        metalView.device = device
        Renderer.commandQueue = Renderer.device.makeCommandQueue()!
        
        //Tells the GPU about the layout of streamed data
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        
        //Generate pipeline descriptor, there is no need to save access to the library, simply parse the metal shaders and assign the functions to the pipeline Descriptor
        let library = Renderer.device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
    
        
        //Create pipeline descriptor and assign shader functions
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        //get pixel format from view
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        originalBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<float3>.stride, options: [])
        
        vertices[0].x += 0.3
        vertices[0].y -= 0.4
        transformedBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<float3>.stride, options: [])
        
        
        vertices[0].x += 0.3
        vertices[0].y -= 0.4
        transformedBuffer2 = device.makeBuffer(bytes: &vertices, length: MemoryLayout<float3>.stride, options: [])
        
        
        //compine all into pipeline state which will be used by draw function
        do{
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error{
            print(error.localizedDescription)
        }
        
        //finally, call super
        super.init()
        
        //set background color for GPU draw
        //metalView.clearColor = MTLClearColor(red: 0.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        //assign metalkitview delegate to self, which starts the draw loop
        metalView.delegate = self
        print("initialised",Renderer.device)
        
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
        
        guard let originalBuffer = originalBuffer,let transformedBuffer = transformedBuffer, let transformedlBuffer2 = transformedBuffer2 else {
            fatalError()
        }
        
        renderEncoder.setVertexBuffer(originalBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        renderEncoder.setFragmentBytes(&magenta, length: MemoryLayout<float4>.stride, index: 0)
        renderEncoder.drawPrimitives(type: ((drawTriangles) ? .triangle : .point), vertexStart: 0, vertexCount: vertices.count)
        
        renderEncoder.setVertexBuffer(transformedBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        renderEncoder.setFragmentBytes(&yellow, length: MemoryLayout<float4>.stride, index: 0)
        renderEncoder.drawPrimitives(type: ((drawTriangles) ? .triangle : .point), vertexStart: 0, vertexCount: vertices.count)

        renderEncoder.setVertexBuffer(transformedlBuffer2, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        renderEncoder.setFragmentBytes(&cyan, length: MemoryLayout<float4>.stride, index: 0)
        renderEncoder.drawPrimitives(type: ((drawTriangles) ? .triangle : .point), vertexStart: 0, vertexCount: vertices.count)
 
        
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
